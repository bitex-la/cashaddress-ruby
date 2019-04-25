require "cashaddress/version"
require 'digest'

module Cashaddress
  def self.to_lookup(array)
    Hash[*array.each_with_index.to_a.flatten]
  end

  CHARSET = "qpzry9x8gf2tvdw0s3jn54khce6mua7l".split('')
  CHARSET_LOOKUP = to_lookup(CHARSET)
  
  # ALPHABET is missing some confusing characters like O and I
  ALPHABET = "123456789ABCDEFGHJKLMNPQRSTUVWXYZabcdefghijkmnopqrstuvwxyz".split('')
  ALPHABET_LOOKUP = to_lookup(ALPHABET)
  
  MAINNET_PREFIX = [2, 9, 20, 3, 15, 9, 14, 3, 1, 19, 8, 0]
  TESTNET_PREFIX = [2, 3, 8, 20, 5, 19, 20, 0]
  REGTEST_PREFIX = [2, 3, 8, 18, 5, 7, 0]

  def self.to_legacy(cashaddress)
    unless match = /(.+?):(.+)/.match(cashaddress)
      raise Error.new("Malformed cashaddress: #{cashaddress}")
    end
    
    is_mainnet = match.captures.first == 'bitcoincash'
    prefix = is_mainnet ? MAINNET_PREFIX.clone : TESTNET_PREFIX.clone
    raw_payload = match.captures.last.split('').map{|m| CHARSET_LOOKUP[m] }
    
    if polymod(prefix + raw_payload) != 0
      raise Error.new("Address checksum invalid: #{cashaddress}")
    end
    
    payload = convert_bits(raw_payload[0..-9], 5, 8, false)
    if payload.empty?
      raise Error.new("Converted payload was empty")
    end
    
    version = if (payload.first >> 3) == 0
      is_mainnet ? 0x00 : 0x6f
    else
      is_mainnet ? 0x05 : 0xc4
    end

    make_old_address(payload[1..21], version)
  end

  def self.make_old_address(payload, version)
    raw = [version] + payload
    digest = Digest::SHA256.digest(Digest::SHA256.digest(raw.pack("C*"))).unpack('C*')
    encode_base58( raw + digest[0..3] )
  end
  
  def self.encode_base58(bytes)
    digits = [0]
    bytes.each do |byte|
      carry = byte
      digits.each_with_index do |digit, index|
        carry += digit << 8
        digits[index] = carry % 58
        carry = ( carry / 58 ) | 0
      end
      
      while carry > 0 
        digits << carry % 58
        carry = (carry / 58) | 0
      end
    end
    
    encoded = ''
    bytes.each do |byte|
      break if byte != 0
      encoded << "1"
    end
    
    encoded << digits.reverse.map{|d| ALPHABET[d] }.join('')

    encoded 
  end

  def self.from_legacy(legacy_address, reg_test = false)
    bytes = [0]
    characters = legacy_address.split('')

    characters.each_with_index do |char, i|
      unless value = ALPHABET_LOOKUP[char]
        raise Error.new("Invalid char #{char}")
      end

      carry = value
      bytes.each_with_index do |byte, j|
        carry += byte * 58
        bytes[j] = carry & 0xff
        carry = carry >> 8
      end

      while carry > 0
        bytes << ( carry & 0xff )
        carry = carry >> 8
      end
    end

    characters.each do |char|
      break if char != "1"
      bytes << 0
    end
    
    if bytes.size < 5
      raise Error.new("Decoded less than 5 bytes from #{legacy_address}")
    end
    
    bytes = bytes.reverse
    version = bytes.first

    digest = Digest::SHA256.digest(Digest::SHA256.digest(bytes[0..-5].pack("C*"))).unpack('C*')

    if digest[0..3] != bytes[-4..-1]
      raise Error.new("Invalid checksum")
    end

    kind, is_main_net = case version
      when 0x00, 0x1c then [0, true]
      when 0x05, 0x28 then [1, true]
      when 0x6f then [0, false]
      when 0xc4 then [1, false]
      else raise Error.new("Unexpected version #{version}")
    end

    make_cashaddress(kind, bytes[1..-5], is_main_net, reg_test)
  end

  def self.make_cashaddress(kind, hash, main_net, reg_test = false)
    packed = convert_bits( [ kind << 3] + hash, 8, 5, true)
    raise Error.new("Can't pack Cashaddress") unless packed

    prefix, address = if reg_test
                        [REGTEST_PREFIX.clone, 'bchreg:']
                      elsif main_net
                        [MAINNET_PREFIX.clone, 'bitcoincash:']
                      else
                        [TESTNET_PREFIX.clone, 'bchtest:']
                      end

    encoded = prefix.concat(packed)
    moduled = polymod(encoded + [0] * 8)
    checksum = 8.times.map do |i|
      shifted = ('%0*b' % [ 5 * (i+1), moduled >> ( 5 * (7-i))])[-5..-1]
        .split('').map(&:to_i)
      to_five_bit_array(shifted).first
    end

    address << (packed + checksum).map{|b| CHARSET[b] }.join('')

    if address.size != 54 && address.size != 50
      raise Error.new("Address is not 50 or 54 characters long #{address}")
    end
    
    address
  end

  def self.to_five_bit_array(array)
    array.each_slice(5).collect do |slice|
      slice.zip([16, 8, 4, 2, 1]).map{|a,b| a * b}.inject(:+)
    end
  end

  def self.convert_bits(data, from, to, pad)
    converted = data
      .map{|i| '%0*b' % [from, i] } # Get chunks <from> bits long
      .join('') # In a long row of zeros and ones.
      .chars.each_slice(to) # Then in bits that are <
      .map{|bits| bits.join('').ljust(to, '0').to_i(2) }
    
    converted = converted[0..-2] if converted.last == 0 && !pad
    converted
  end

  # Polymod checksum is defined in the cashaddr spec
  # https://github.com/Bitcoin-UAHF/spec/blob/master/cashaddr.md
  def self.polymod(vector)
    accum = 1
    vector.each do |byte|
      pivot = accum >> 35
      accum = ((accum & 0x07ffffffff) << 5) ^ byte
  
      [
       [0x01, 0x98f2bc8e61],
       [0x02, 0x79b76d99e2],
       [0x04, 0xf33e5fb3c4],
       [0x08, 0xae2eabe2a8],
       [0x10, 0x1e4f43e470],
      ].each do |bit, mask|
        accum ^= mask if (pivot & bit) != 0
      end
    end
    accum ^ 1
  end

  class Error < StandardError; end;
end

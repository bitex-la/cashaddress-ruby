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

	def self.from_legacy(legacy_address)
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

		make_cashaddress(kind, bytes[1..-5], is_main_net)
	end

  def self.make_cashaddress(kind, hash, main_net)
    packed = convert_bits( [ kind << 3] + hash, 8, 5, true)
    raise Error.new("Can't pack Cashaddress") unless packed

    expand_prefix = if main_net
      [2, 9, 20, 3, 15, 9, 14, 3, 1, 19, 8, 0]
    else
      [2, 3, 8, 20, 5, 19, 20, 0]
    end

    encoded = expand_prefix.concat(packed)
		puts "hash is #{hash}"
		puts "encoded is #{encoded}"
    modulus = polymod(encoded + [0] * 8)
		checksum = 8.times.map do |i|
			shifted = (modulus >> ( 5 * (7-i))).unpack("B*")[0]
			toFiveBitArray(shifted)
		end

		combined = packed + checksum
		
		address = main_net ? "bitcoincash:" : "bchtest:"

		address << combined.map{|b| CHARSET[b] }.join('')

		if address.size != 54 || address.size != 50
			raise Error.new("Address is not 50 or 54 characters long #{address}")
		end
		
		address
  end

	def self.toFiveBitArray(array)
		array.each_slice(5).collect do |slice|
			slice.zip([16, 8, 4, 2, 1]).map{|a,b| a * b}.sum
		end
	end

  #def convert_base(from, to)
  #   self.to_i(from).to_s(to)
  #    end
  def self.convert_bits(data, from, to, pad)
    accum = 0
    bits = 0
    converted = []
    max_value = (1 << to) - 1
    max_accum = ( 1 << (from + to - 1)) - 1
    data.each do |value|
      return if value < 0 || (value >> from) != 0
      accum = ((accum << from) | value) & max_accum
      bits += from
      while bits >= to
        bits -= to
        converted << ((accum >> bits) & max_value )
      end
    end

    if pad
      if bits > 0
        converted << ( (accum << (to - bits) ) & max_value )
      end
    elsif bits >= from || (( accum << (to - bits )) & max_value) != 0 
      return nil
    end

    converted
  end

	# Polymod checksum is defined in the cashaddr spec
  # https://github.com/Bitcoin-UAHF/spec/blob/master/cashaddr.md
  def self.polymod(v)
		c = 1
		v.each do |d|
			c0 = c >> 35
			c = ((c & 0x07ffffffff) << 5) ^ d
			
			c ^= case c >> 35
				when 0x01 then 0x98f2bc8e61 
				when 0x02 then 0x79b76d99e2
				when 0x04 then 0xf33e5fb3c4
				when 0x08 then 0xae2eabe2a8
				when 0x10 then 0x1e4f43e470
			end
		end
		c ^ 1
  end

	class Error < StandardError; end;
end

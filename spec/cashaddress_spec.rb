require 'spec_helper'

RSpec.describe Cashaddress do
  it 'has a version number' do
    expect(Cashaddress::VERSION).not_to be nil
  end

  {
    '1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu' => 'bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a',
    '1KXrWXciRDZUpQwQmuM1DbwsKDLYAYsVLR' => 'bitcoincash:qr95sy3j9xwd2ap32xkykttr4cvcu7as4y0qverfuy',
    '16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDXb'  => 'bitcoincash:qqq3728yw0y47sqn6l2na30mcw6zm78dzqre909m2r',
    '3CWFddi6m4ndiGyKqzYvsFYagqDLPVMTzC' => 'bitcoincash:ppm2qsznhks23z7629mms6s4cwef74vcwvn0h829pq',
    '3LDsS579y7sruadqu11beEJoTjdFiFCdX4' => 'bitcoincash:pr95sy3j9xwd2ap32xkykttr4cvcu7as4yc93ky28e',
    '31nwvkZwyPdgzjBJZXfDmSWsC4ZLKpYyUw' => 'bitcoincash:pqq3728yw0y47sqn6l2na30mcw6zm78dzq5ucqzc37',
    'mrLC19Je2BuWQDkWSTriGYPyQJXKkkBmCx' => 'bchtest:qpm2qsznhks23z7629mms6s4cwef74vcwvqcw003ap',
    'mz3ooahhEEzjbXR2VUKP3XACBCwF5zhQBy' => 'bchtest:qr95sy3j9xwd2ap32xkykttr4cvcu7as4ytjg7p7mc',
    'mfctJGAVEWkZgfxV9zy1AjNFuXsKi2VXB8' => 'bchtest:qqq3728yw0y47sqn6l2na30mcw6zm78dzq8tpg8vdl',
    '2N44ThNe8NXHyv4bsX8AoVCXquBRW94Ls7W' => 'bchtest:ppm2qsznhks23z7629mms6s4cwef74vcwvhanqgjxu',
    '2NBn5Vp3BaaPD7NGPa8dUGBJ4g5qRXq92wG' => 'bchtest:pr95sy3j9xwd2ap32xkykttr4cvcu7as4yuh43xaq9',
    '2MsM9zVVyar93CWorEfH6PPW8QQmW3s1uh6' => 'bchtest:pqq3728yw0y47sqn6l2na30mcw6zm78dzqswu8q0kz',
  }.each do |legacy, cashaddress|
    it "translates #{cashaddress} to legacy" do
      expect(Cashaddress.to_legacy(cashaddress)).to eq legacy
    end
    it "translates #{legacy} to cashaddress" do
      expect(Cashaddress.from_legacy(legacy.to_s)).to eq cashaddress
    end
  end

  {
    'mrLC19Je2BuWQDkWSTriGYPyQJXKkkBmCx' => 'bchreg:qpm2qsznhks23z7629mms6s4cwef74vcwv6ycwvz78',
    'mz3ooahhEEzjbXR2VUKP3XACBCwF5zhQBy' => 'bchreg:qr95sy3j9xwd2ap32xkykttr4cvcu7as4y3w7lzdc7',
    'mfctJGAVEWkZgfxV9zy1AjNFuXsKi2VXB8' => 'bchreg:qqq3728yw0y47sqn6l2na30mcw6zm78dzqahhfylwe',
    '2N44ThNe8NXHyv4bsX8AoVCXquBRW94Ls7W' => 'bchreg:ppm2qsznhks23z7629mms6s4cwef74vcwvdp9ptp96',
    '2NBn5Vp3BaaPD7NGPa8dUGBJ4g5qRXq92wG' => 'bchreg:pr95sy3j9xwd2ap32xkykttr4cvcu7as4yxtrs9wrr',
    '2MsM9zVVyar93CWorEfH6PPW8QQmW3s1uh6' => 'bchreg:pqq3728yw0y47sqn6l2na30mcw6zm78dzq2j2xru4y',
  }.each do |legacy, cashaddress|
    it "translates #{cashaddress} to legacy (regtest)" do
      expect(Cashaddress.to_legacy(cashaddress, true)).to eq legacy
    end
    it "translates #{legacy} to cashaddress (regtest)" do
      expect(Cashaddress.from_legacy(legacy.to_s, true)).to eq cashaddress
    end
  end
  
  {
    'needs a prefix' =>   'pqq3728yw0y47sqn6l2na30mcw6zm78dzq5ucqzc37',
    'has invalid checksum' => 'bitcoincash:pqq3728yw0y47sqn6l2na30mcw6z378dzq5ucqzc37',
    'it is empty' => 'ee:',
  }.each do |reason, address|
    it "fails converting to legacy because it #{reason}" do
      expect do
        Cashaddress.to_legacy(address)
      end.to raise_exception{ Cashaddress::Error }
    end
  end

  {
    'it is empty' => '',
    'has invalid checksum' => 'b16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDX',
  }.each do |reason, address|
    it "fails converting from legacy because it #{reason}" do
      expect do
        Cashaddress.from_legacy(address)
      end.to raise_exception{ Cashaddress::Error }
    end
  end
end

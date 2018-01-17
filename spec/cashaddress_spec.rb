require "spec_helper"

RSpec.describe Cashaddress do
  it "has a version number" do
    expect(Cashaddress::VERSION).not_to be nil
  end

  {
    "1BpEi6DfDAUFd7GtittLSdBeYJvcoaVggu": "bitcoincash:qpm2qsznhks23z7629mms6s4cwef74vcwvy22gdx6a",
  }.each do |legacy, cashaddress|
    it "Translates #{legacy} to cashaddress" do
      Cashaddress.from_legacy(legacy.to_s).should == cashaddress
    end
  end
=begin
    #it "Translates #{cashaddress} to legacy" do
    "1KXrWXciRDZUpQwQmuM1DbwsKDLYAYsVLR": "bitcoincash:qr95sy3j9xwd2ap32xkykttr4cvcu7as4y0qverfuy",
    "16w1D5WRVKJuZUsSRzdLp9w3YGcgoxDXb":  "bitcoincash:qqq3728yw0y47sqn6l2na30mcw6zm78dzqre909m2r",
    "3CWFddi6m4ndiGyKqzYvsFYagqDLPVMTzC": "bitcoincash:ppm2qsznhks23z7629mms6s4cwef74vcwvn0h829pq",
    "3LDsS579y7sruadqu11beEJoTjdFiFCdX4": "bitcoincash:pr95sy3j9xwd2ap32xkykttr4cvcu7as4yc93ky28e",
    "31nwvkZwyPdgzjBJZXfDmSWsC4ZLKpYyUw": "bitcoincash:pqq3728yw0y47sqn6l2na30mcw6zm78dzq5ucqzc37"
      #Cashaddress.to_legacy(cashaddress).should == legacy
    #end
  end
=end
end

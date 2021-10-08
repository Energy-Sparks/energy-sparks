require 'rails_helper'

module Cads
  describe SyntheticDataService do

    let(:school)    { create(:school) }
    let(:cad)       { create(:cad, school: school, max_power: max_power) }
    let(:max_power) { 100 }

    before :each do
      @service = Cads::SyntheticDataService.new(cad)
    end

    it "incrememnts reading by 10% each call and loops" do
      expect(@service.read).to eq(10.0)
      expect(@service.read).to eq(20.0)
      expect(@service.read).to eq(30.0)
      # etc
      6.times { @service.read }
      expect(@service.read).to eq(100.0)
      expect(@service.read).to eq(0.0)
    end

    it "sets a timestamp" do
      expect(cad.last_read_at).to be_nil
      @service.read
      expect(cad.last_read_at).to_not be_nil
    end

    # context 'when max is set' do
    #   let(:max_power) { 3 }
    #   it "returns random number less than max" do
    #     result = Cads::SyntheticDataService.new(cad).read
    #     expect(result).not_to be_nil
    #     expect(result < max_power).to be true
    #   end
    # end
    #
    # context 'when max is not set' do
    #   let(:max_power) { }
    #   it "returns random number less than default" do
    #     result = Cads::SyntheticDataService.new(cad).read
    #     expect(result).not_to be_nil
    #     expect(result < 100).to be true
    #   end
    # end
  end
end

require 'rails_helper'

module Cads
  describe SyntheticDataService do

    let(:school)  { create(:school) }
    let(:cad)     { create(:cad, school: school, max_power: max_power) }

    context 'when max is set' do
      let(:max_power) { 3 }
      it "returns random number less than max" do
        result = Cads::SyntheticDataService.new(cad).read
        expect(result).not_to be_nil
        expect(result < max_power).to be true
      end
    end

    context 'when max is not set' do
      let(:max_power) { }
      it "returns random number less than default" do
        result = Cads::SyntheticDataService.new(cad).read
        expect(result).not_to be_nil
        expect(result < 100).to be true
      end
    end
  end
end

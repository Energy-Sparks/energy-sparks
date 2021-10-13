require 'rails_helper'

module Cads
  describe SyntheticDataService do

    let(:school)    { create(:school) }
    let(:cad)       { create(:cad, school: school, max_power: max_power) }
    let(:max_power) { 3 }

    before :each do
      @service = Cads::SyntheticDataService.new(cad)
    end

    it "gives varying readings between 0 and max power" do
      readings = []
      10.times { readings << @service.read }
      readings.each { |reading| expect(reading).to be_between(0, max_power) }
      expect(readings.uniq.count).to be > 1
    end
  end
end

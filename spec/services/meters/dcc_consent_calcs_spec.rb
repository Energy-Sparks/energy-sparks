require 'rails_helper'

module Meters
  describe DccConsentCalcs do

    let(:school_1) { create(:school) }
    let(:school_2) { create(:school) }
    let(:school_3) { create(:school) }
    let(:meter_1)  { create(:electricity_meter, school: school_1, consent_granted: true) }
    let(:meter_2)  { create(:electricity_meter, school: school_1, consent_granted: false) }
    let(:meter_3)  { create(:electricity_meter, school: school_2, consent_granted: true) }
    let(:meter_4)  { create(:electricity_meter, school: school_3, consent_granted: false) }

    let(:meters)         { [meter_1, meter_2, meter_3, meter_4] }
    let(:dcc_consents)   { [] }

    let(:calcs)  { Meters::DccConsentCalcs.new(meters, dcc_consents) }

    it "should give count of consented meters" do
      expect(calcs.total_meters_with_consents).to eq(2)
    end

    it "should give count of consented schools" do
      expect(calcs.total_schools_with_consents).to eq(2)
    end
  end
end

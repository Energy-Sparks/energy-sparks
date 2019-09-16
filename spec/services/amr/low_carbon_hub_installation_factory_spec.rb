require 'rails_helper'
require 'dashboard'

module Amr
  describe LowCarbonHubInstallationFactory do

    let!(:school)              { create(:school) }
    let(:low_carbon_hub_api)  { double("low_carbon_hub_api") }
    let(:rbee_meter_id)       { 216057958 }
    let(:information)         { { info: 'Some info' } }
    let(:start_date)          { Date.parse('02/08/2016') }
    let(:end_date)            { start_date + 1.day }
    let(:readings)            {
      {
        solar_pv: {
          mpan_mprn: 70000000123085,
          readings: {
            start_date => OneDayAMRReading.new(70000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(70000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        electricity: {
          mpan_mprn: 90000000123085,
          readings: {
            start_date => OneDayAMRReading.new(90000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(90000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
        exported_solar_pv: {
          mpan_mprn: 60000000123085,
          readings: {
            start_date => OneDayAMRReading.new(60000000123085, start_date, 'ORIG', nil, start_date, Array.new(48, 0.25)),
            end_date => OneDayAMRReading.new(60000000123085, end_date, 'ORIG', nil, end_date, Array.new(48, 0.5))
          }
        },
      }
    }

    it 'creates the meters' do
      expect(low_carbon_hub_api).to receive(:full_installation_information).with(rbee_meter_id).and_return(information)
      expect(low_carbon_hub_api).to receive(:first_meter_reading_date).with(rbee_meter_id).and_return(start_date)
      expect(low_carbon_hub_api).to receive(:download).with(rbee_meter_id, school.urn, start_date, end_date).and_return(readings)

      factory = LowCarbonHubInstallationFactory.new(school: school, rbee_meter_id: rbee_meter_id, low_carbon_hub_api: low_carbon_hub_api)
      expect { factory.perform }.to change { Meter.count }.by(3)
      expect(Meter.solar_pv.count).to be 1
      expect(Meter.electricity.count).to be 1
      expect(Meter.exported_solar_pv.count).to be 1

      expect(Meter.solar_pv.first.mpan_mprn).to be readings[:solar_pv][:mpan_mprn]
      expect(Meter.electricity.first.mpan_mprn).to be readings[:electricity][:mpan_mprn]
      expect(Meter.exported_solar_pv.first.mpan_mprn).to be readings[:exported_solar_pv][:mpan_mprn]
    end
  end
end

require 'rails_helper'
require 'dashboard'

module Amr
  describe LowCarbonHubInstallationFactory do
    include_context "low carbon hub data"

    before(:each) do
      expect(low_carbon_hub_api).to receive(:full_installation_information).with(rbee_meter_id).and_return(information)
      expect(low_carbon_hub_api).to receive(:first_meter_reading_date).with(rbee_meter_id).and_return(start_date)
      expect(low_carbon_hub_api).to receive(:download).with(rbee_meter_id, school.urn, start_date, end_date).and_return(readings)
    end

    it 'creates the meters and initial readings' do
      expect(amr_data_feed_config).to_not be nil

      factory = LowCarbonHubInstallationFactory.new(school: school, rbee_meter_id: rbee_meter_id, low_carbon_hub_api: low_carbon_hub_api, amr_data_feed_config: amr_data_feed_config)
      expect { factory.perform }.to change { Meter.count }.by(3)
      expect(school.meters.solar_pv.count).to be 1
      expect(school.meters.electricity.count).to be 1
      expect(school.meters.exported_solar_pv.count).to be 1

      solar_pv_meter = school.meters.solar_pv.first
      electricity_meter = school.meters.electricity.first
      exported_solar_pv_meter = school.meters.exported_solar_pv.first

      expect(solar_pv_meter.mpan_mprn).to be readings[:solar_pv][:mpan_mprn]
      expect(electricity_meter.mpan_mprn).to be readings[:electricity][:mpan_mprn]
      expect(exported_solar_pv_meter.mpan_mprn).to be readings[:exported_solar_pv][:mpan_mprn]

      expect(solar_pv_meter.amr_data_feed_readings.count).to be 2
      expect(electricity_meter.amr_data_feed_readings.count).to be 2
      expect(exported_solar_pv_meter.amr_data_feed_readings.count).to be 2

      expect(solar_pv_meter.pseudo).to be true
      expect(electricity_meter.pseudo).to be true
      expect(exported_solar_pv_meter.pseudo).to be true
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

module Solar
  describe LowCarbonHubInstallationFactory do
    include_context 'low carbon hub data'

    it 'creates the meters and initial readings' do
      allow(DataFeeds::LowCarbonHubMeterReadings).to receive(:new).and_return(low_carbon_hub_api)

      expect(amr_data_feed_config).not_to be_nil

      factory = described_class.new(
        ActiveSupport::OrderedOptions.new.merge(school:, rbee_meter_id:, username:, password:, active: true),
        amr_data_feed_config
      )
      expect { factory.perform }.to change(Meter, :count).by(3)
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

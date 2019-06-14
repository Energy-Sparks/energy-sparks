require 'dashboard'
require 'rails_helper'

module Amr
  describe AnalyticsValidatedMeterCollectionFactory do

    let(:school_name) { 'Active school'}
    let!(:school)     { create(:school, :with_school_group, name: school_name) }
    let!(:config)     { create(:amr_data_feed_config) }
    let!(:e_meter)    { create(:electricity_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'), end_date: Date.parse('02/06/2019'), school: school) }
    let!(:g_meter)    { create(:gas_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'), end_date: Date.parse('02/06/2019'), school: school) }

    it 'builds an Validated meter collection' do
      meter_collection = AnalyticsValidatedMeterCollectionFactory.new(school, MeterCollection, 1).build

      expect(e_meter.amr_validated_readings.count).to be 2

      expect(meter_collection.name).to eq school_name
      expect(meter_collection.address).to eq school.address
      expect(meter_collection.postcode).to eq school.postcode
      expect(meter_collection.urn).to eq school.urn
      expect(meter_collection.number_of_pupils).to eq school.number_of_pupils

      first_electricity_meter = meter_collection.electricity_meters.first

      expect(first_electricity_meter.mpan_mprn).to eq e_meter.mpan_mprn
      expect(first_electricity_meter.amr_data.keys.size).to eq 2
      expect(first_electricity_meter.amr_data.keys.first).to eq e_meter.amr_validated_readings.first.reading_date
      expect(first_electricity_meter.amr_data.values.first.kwh_data_x48).to eq e_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)

      first_gas_meter = meter_collection.heat_meters.first

      expect(first_gas_meter.mpan_mprn).to eq g_meter.mpan_mprn
      expect(first_gas_meter.amr_data.keys.first).to eq g_meter.amr_validated_readings.first.reading_date
      expect(first_gas_meter.amr_data.values.first.kwh_data_x48).to eq g_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)
    end
  end
end

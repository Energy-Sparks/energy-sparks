require 'dashboard'
require 'rails_helper'

module Amr
  describe AnalyticsUnvalidatedMeterCollectionFactory do

    let(:school_name) { 'Active school'}
    let!(:school)     { create(:school, :with_school_group, name: school_name) }
    let!(:config)     { create(:amr_data_feed_config) }
    let!(:e_meter)    { create(:electricity_meter_with_reading, reading_count: 2, school: school, config: config) }
    let!(:g_meter)    { create(:gas_meter_with_reading, school: school) }

    it 'builds an unvalidated meter collection' do
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build

      expect(e_meter.amr_data_feed_readings.count).to be 2

      expect(meter_collection.name).to eq school_name
      expect(meter_collection.address).to eq school.address
      expect(meter_collection.postcode).to eq school.postcode
      expect(meter_collection.urn).to eq school.urn
      expect(meter_collection.number_of_pupils).to eq school.number_of_pupils

      first_electricity_meter = meter_collection.electricity_meters.first

      expect(first_electricity_meter.mpan_mprn).to eq e_meter.mpan_mprn
      expect(first_electricity_meter.amr_data.keys.size).to eq 2
      expect(first_electricity_meter.amr_data.keys.first).to eq Date.parse(e_meter.amr_data_feed_readings.first.reading_date)
      expect(first_electricity_meter.amr_data.values.first.kwh_data_x48).to eq e_meter.amr_data_feed_readings.first.readings.map(&:to_f)

      first_gas_meter = meter_collection.heat_meters.first

      expect(first_gas_meter.mpan_mprn).to eq g_meter.mpan_mprn
      expect(first_gas_meter.amr_data.keys.first).to eq Date.parse(g_meter.amr_data_feed_readings.first.reading_date)
      expect(first_gas_meter.amr_data.values.first.kwh_data_x48).to eq g_meter.amr_data_feed_readings.first.readings.map(&:to_f)
    end

    it 'skips invalid date formats' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, rand), reading_date: Date.tomorrow.strftime('%b %e %Y'), mpan_mprn: e_meter.mpan_mprn)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build
      expect(meter_collection.electricity_meters.first.amr_data.keys.size).to eq 2
    end

    it 'skips blank readings' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, nil), reading_date: Date.tomorrow.strftime('%b %e %Y'), mpan_mprn: e_meter.mpan_mprn)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build
      expect(meter_collection.electricity_meters.first.amr_data.keys.size).to eq 2
    end
  end
end
require 'rails_helper'

module Amr
  describe AnalyticsUnvalidatedMeterCollectionFactory do

    let(:school_name) { 'Active school'}
    let!(:school)     { create(:school, :with_school_group, name: school_name) }
    let!(:config)     { create(:amr_data_feed_config) }
    let!(:log)        { create(:amr_data_feed_import_log) }
    let!(:e_meter)    { create(:electricity_meter_with_reading, reading_count: 2, school: school, config: config) }
    let!(:g_meter)    { create(:gas_meter_with_reading, school: school) }

    it 'builds an unvalidated meter collection' do
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build

      expect(e_meter.amr_data_feed_readings.count).to be 2

      expect(meter_collection.name).to eq school_name
      expect(meter_collection.address).to eq school.address
      expect(meter_collection.postcode).to eq school.postcode
      expect(meter_collection.floor_area.class).to eq Float
      expect(meter_collection.urn).to eq school.urn
      expect(meter_collection.number_of_pupils).to eq school.number_of_pupils

      first_electricity_meter = meter_collection.electricity_meters.first

      expect(first_electricity_meter.mpan_mprn).to eq e_meter.mpan_mprn
      expect(first_electricity_meter.amr_data.keys.size).to eq 2

      expect(first_electricity_meter.amr_data.keys.sort.reverse).to match_array e_meter.amr_data_feed_readings.map {|reading| Date.parse(reading.reading_date) }.flatten

      expect( first_electricity_meter.amr_data.values.map { |reading| reading.kwh_data_x48 }).to match_array e_meter.amr_data_feed_readings.map { |reading| reading.readings.map(&:to_f) }

      first_gas_meter = meter_collection.heat_meters.first

      expect(first_gas_meter.mpan_mprn).to eq g_meter.mpan_mprn
      expect(first_gas_meter.amr_data.keys.first).to eq Date.parse(g_meter.amr_data_feed_readings.first.reading_date)
      expect(first_gas_meter.amr_data.values.first.kwh_data_x48).to eq g_meter.amr_data_feed_readings.first.readings.map(&:to_f)
    end

    it 'ends up with the last created reading if there are two for the same data' do
      existing_readings = []

      e_meter.amr_data_feed_readings.each do |existing_reading|
        existing_readings << existing_reading.readings.map(&:to_f)
        create(:amr_data_feed_reading, meter: e_meter, reading_date: existing_reading.reading_date, amr_data_feed_config: existing_reading.amr_data_feed_config, created_at: Date.parse('01/01/2019'))
      end

      e_meter.reload
      expect(e_meter.amr_data_feed_readings.count).to be 4

      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build

      first_electricity_meter = meter_collection.electricity_meters.first

      expect(first_electricity_meter.amr_data.keys.size).to eq 2
      expect( first_electricity_meter.amr_data.values.map { |reading| reading.kwh_data_x48 }).to match_array existing_readings
    end

    it 'fallsback to date parse where the specified format does not work' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, rand), reading_date: Date.tomorrow.strftime('%d/%m/%Y'), mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build
      expect(meter_collection.electricity_meters.first.amr_data.keys.size).to eq 3
      expect(meter_collection.electricity_meters.first.amr_data.keys).to include Date.tomorrow
    end

    it 'skips invalid date formats' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, rand), reading_date: 'baddate', mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build
      expect(meter_collection.electricity_meters.first.amr_data.keys.size).to eq 2
    end

    it 'skips blank readings' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, nil), reading_date: Date.tomorrow.strftime('%b %e %Y'), mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      meter_collection = AnalyticsUnvalidatedMeterCollectionFactory.new(school).build
      expect(meter_collection.electricity_meters.first.amr_data.keys.size).to eq 2
    end
  end
end

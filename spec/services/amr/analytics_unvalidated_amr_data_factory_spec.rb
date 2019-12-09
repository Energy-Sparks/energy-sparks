require 'rails_helper'

module Amr
  describe AnalyticsUnvalidatedAmrDataFactory do

    let(:school_name) { 'Active school'}
    let!(:school)     { create(:school, :with_school_group, name: school_name) }
    let!(:config)     { create(:amr_data_feed_config) }
    let!(:log)        { create(:amr_data_feed_import_log) }
    let!(:e_meter)    { create(:electricity_meter_with_reading, reading_count: 2, school: school, config: config) }
    let!(:g_meter)    { create(:gas_meter_with_reading, school: school) }

    it 'builds an unvalidated meter collection' do
      amr_data = AnalyticsUnvalidatedAmrDataFactory.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build

      expect(e_meter.amr_data_feed_readings.count).to be 2

      first_electricity_meter = amr_data[:electricity_meters].first

      expect(first_electricity_meter[:identifier]).to eq e_meter.mpan_mprn
      expect(first_electricity_meter[:readings].size).to eq 2
      expect(first_electricity_meter[:readings].map { |reading| reading[:kwh_data_x48] }).to match_array e_meter.amr_data_feed_readings.map { |reading| reading.readings.map(&:to_f) }

      first_gas_meter = amr_data[:heat_meters].first

      expect(first_gas_meter[:identifier]).to eq g_meter.mpan_mprn
      expect(first_gas_meter[:readings].first[:reading_date]).to eq Date.parse(g_meter.amr_data_feed_readings.first.reading_date)
      expect(first_gas_meter[:readings].first[:kwh_data_x48]).to eq g_meter.amr_data_feed_readings.first.readings.map(&:to_f)
    end

    it 'fallsback to date parse where the specified format does not work' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, rand), reading_date: Date.tomorrow.strftime('%d/%m/%Y'), mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      amr_data = AnalyticsUnvalidatedAmrDataFactory.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build
      expect(amr_data[:electricity_meters].first[:readings].size).to eq 3
      expect(amr_data[:electricity_meters].first[:readings].map{|reading| reading[:reading_date]}).to include Date.tomorrow
    end

    it 'skips invalid date formats' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, rand), reading_date: 'baddate', mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      amr_data = AnalyticsUnvalidatedAmrDataFactory.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build
      expect(amr_data[:electricity_meters].first[:readings].size).to eq 2
    end

    it 'skips blank readings' do
      e_meter.amr_data_feed_readings << AmrDataFeedReading.create!(meter: e_meter, amr_data_feed_config: config, readings: Array.new(48, nil), reading_date: Date.tomorrow.strftime('%b %e %Y'), mpan_mprn: e_meter.mpan_mprn, amr_data_feed_import_log: log)

      expect(e_meter.amr_data_feed_readings.count).to be 3
      amr_data = AnalyticsUnvalidatedAmrDataFactory.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build
      expect(amr_data[:electricity_meters].first[:readings].size).to eq 2
    end
  end
end

require 'dashboard'
require 'rails_helper'

module Amr
  describe AnalyticsValidatedAmrDataFactory do

    let(:school_name) { 'Active school'}
    let!(:school)     { create(:school, :with_school_group, name: school_name) }
    let!(:config)     { create(:amr_data_feed_config) }
    let!(:e_meter)    { create(:electricity_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'), end_date: Date.parse('02/06/2019'), school: school) }
    let!(:g_meter)    { create(:gas_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'), end_date: Date.parse('02/06/2019'), school: school) }

    it 'builds an Validated meter collection' do
      amr_data = AnalyticsValidatedAmrDataFactory.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build

      expect(e_meter.amr_validated_readings.count).to be 2

      first_electricity_meter = amr_data[:electricity_meters].first

      expect(first_electricity_meter[:identifier]).to eq e_meter.mpan_mprn
      expect(first_electricity_meter[:readings].size).to eq 2
      expect(first_electricity_meter[:readings].first[:reading_date]).to eq e_meter.amr_validated_readings.first.reading_date
      expect(first_electricity_meter[:readings].first[:kwh_data_x48]).to eq e_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)

      first_gas_meter = amr_data[:heat_meters].first

      expect(first_gas_meter[:identifier]).to eq g_meter.mpan_mprn
      expect(first_gas_meter[:readings].first[:reading_date]).to eq g_meter.amr_validated_readings.first.reading_date
      expect(first_gas_meter[:readings].first[:kwh_data_x48]).to eq g_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)
    end
  end
end

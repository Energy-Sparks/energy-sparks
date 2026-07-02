# frozen_string_literal: true

require 'dashboard'
require 'rails_helper'

module Amr
  describe AnalyticsValidatedAmrDataFactory do
    let!(:school)     { create(:school, :with_school_group) }
    let!(:e_meter)    do
      create(:electricity_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'),
                                                              end_date: Date.parse('02/06/2019'), school:)
    end
    let!(:g_meter) do
      create(:gas_meter_with_validated_reading_dates, start_date: Date.parse('01/06/2019'),
                                                      end_date: Date.parse('02/06/2019'), school:)
    end

    subject(:amr_data) { described_class.new(heat_meters: [g_meter], electricity_meters: [e_meter]).build }

    it 'builds the electricity meters' do
      expect(e_meter.amr_validated_readings.count).to be 2
      first_electricity_meter = amr_data[:electricity_meters].first
      expect(first_electricity_meter[:identifier]).to eq e_meter.mpan_mprn
      expect(first_electricity_meter[:readings].size).to eq 2
      expect(first_electricity_meter[:readings].first.date).to eq e_meter.amr_validated_readings.first.reading_date
      expected_readings = e_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)
      expect(first_electricity_meter[:readings].first.kwh_data_x48).to eq expected_readings
    end

    it 'builds the gas meters' do
      first_gas_meter = amr_data[:heat_meters].first
      expect(first_gas_meter[:identifier]).to eq g_meter.mpan_mprn
      expect(first_gas_meter[:readings].first.date).to eq g_meter.amr_validated_readings.first.reading_date
      expected_readings = g_meter.amr_validated_readings.first.kwh_data_x48.map(&:to_f)
      expect(first_gas_meter[:readings].first.kwh_data_x48).to eq expected_readings
    end
  end
end

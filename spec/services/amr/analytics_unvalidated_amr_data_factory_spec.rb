require 'rails_helper'

module Amr
  describe AnalyticsUnvalidatedAmrDataFactory do
    subject(:factory) { described_class.new(heat_meters: [g_meter], electricity_meters: [e_meter]) }

    let!(:school)     { create(:school, :with_school_group) }
    let!(:e_meter)    { create(:electricity_meter_with_reading, reading_count: 2, school: school) }
    let!(:g_meter)    { create(:gas_meter_with_reading, school: school, dcc_meter: :smets2) }

    context 'with valid data' do
      let(:amr_data) { factory.build }

      it 'creates electricity meters' do
        first_electricity_meter = amr_data[:electricity_meters].first

        expect(first_electricity_meter[:identifier]).to eq e_meter.mpan_mprn
        expect(first_electricity_meter[:dcc_meter]).to be false
        expect(first_electricity_meter[:readings].size).to eq 2
        expect(first_electricity_meter[:readings].map(&:kwh_data_x48)).to match_array(e_meter.amr_data_feed_readings.map { |reading| reading.readings.map(&:to_f) })
      end

      it 'creates gas meters' do
        first_gas_meter = amr_data[:heat_meters].first

        expect(first_gas_meter[:identifier]).to eq g_meter.mpan_mprn
        expect(first_gas_meter[:dcc_meter]).to be true
        expect(first_gas_meter[:readings].first.date).to eq Date.parse(g_meter.amr_data_feed_readings.first.reading_date)
        expect(first_gas_meter[:readings].first.kwh_data_x48).to eq g_meter.amr_data_feed_readings.first.readings.map(&:to_f)
      end
    end

    context 'with invalid data' do
      let(:amr_data) { factory.build }

      context 'with an invalid date' do
        before do
          create(:amr_data_feed_reading,
            meter: e_meter,
            readings: Array.new(48, rand),
            reading_date: Date.tomorrow.strftime('%d/%m/%Y'),
            mpan_mprn: e_meter.mpan_mprn)
        end

        it 'falls back to Date.parse' do
          expect(e_meter.amr_data_feed_readings.count).to be 3
          expect(amr_data[:electricity_meters].first[:readings].size).to eq 3
          expect(amr_data[:electricity_meters].first[:readings].map(&:date)).to include Date.tomorrow
        end
      end

      context 'with an unparseable date' do
        before do
          create(:amr_data_feed_reading,
            meter: e_meter,
            readings: Array.new(48, rand),
            reading_date: 'baddate',
            mpan_mprn: e_meter.mpan_mprn)
        end

        it 'skips the row' do
          expect(e_meter.amr_data_feed_readings.count).to be 3
          expect(amr_data[:electricity_meters].first[:readings].size).to eq 2
        end
      end

      context 'with blank readings' do
        before do
          create(:amr_data_feed_reading,
            meter: e_meter,
            readings: Array.new(48, nil),
            reading_date: Date.tomorrow.strftime('%b %e %Y'),
            mpan_mprn: e_meter.mpan_mprn)
        end

        it 'skips blank readings' do
          expect(e_meter.amr_data_feed_readings.count).to be 3
          expect(amr_data[:electricity_meters].first[:readings].size).to eq 2
        end
      end

      context 'with partial readings for day' do
        let(:amr_data_feed_config) { create(:amr_data_feed_config, row_per_reading: false, missing_readings_limit: nil) }

        before do
          create(:amr_data_feed_reading,
            meter: e_meter,
            amr_data_feed_config: amr_data_feed_config,
            readings: [1.23] + Array.new(47, nil),
            reading_date: Date.tomorrow.strftime('%b %e %Y'),
            mpan_mprn: e_meter.mpan_mprn)
        end

        context 'with no readings limit' do
          # TODO this SHOULD preserve nils without converting to 0.0, once the analytics can handle it
          it 'converts nil to 0.0' do
            expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[0]).to be 1.23
            expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[1]).to be 0.0
            expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[47]).to be 0.0
          end
        end

        context 'with a missing_readings_limit' do
          context 'when above the threshold' do
            let(:amr_data_feed_config) { create(:amr_data_feed_config, row_per_reading: true, missing_readings_limit: 3) }

            it 'rejects the day' do
              expect(e_meter.amr_data_feed_readings.count).to be 3
              expect(amr_data[:electricity_meters].first[:readings].size).to eq 2
            end
          end

          context 'when below the threshold' do
            let(:amr_data_feed_config) { create(:amr_data_feed_config, row_per_reading: true, missing_readings_limit: 47) }

            it 'converts nil to 0.0' do
              expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[0]).to be 1.23
              expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[1]).to be 0.0
              expect(amr_data[:electricity_meters].last[:readings].last.kwh_data_x48[47]).to be 0.0
            end
          end
        end
      end
    end
  end
end

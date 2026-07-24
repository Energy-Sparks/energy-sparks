# frozen_string_literal: true

require 'rails_helper'

describe Amr::N3rgyDownloader do
  subject(:service) { described_class.new(meter:, start_date:, end_date:) }

  let(:meter)     { create(:electricity_meter) }
  let(:config)    { create(:amr_data_feed_config) }
  let(:end_date)  { Time.zone.today }
  let(:start_date) { end_date - 1 }

  describe '#readings' do
    subject(:readings) { service.readings }

    let(:stub) { instance_double(DataFeeds::N3rgy::DataApiClient) }

    before do
      allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(stub)
      allow(stub).to receive(:readings).with(meter.mpan_mprn, meter.fuel_type.to_s,
                                             DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION,
                                             anything, anything)
                                       .and_return(response)
    end

    context 'with a period of more than 90 days' do
      let(:start_date) { DateTime.new(2023, 1, 1, 0, 30) }
      let(:end_date) { DateTime.new(2023, 4, 11, 0, 0) } # 100 days ahead
      let(:response) { { 'devices' => [{ 'values' => [] }] } }

      it 'makes multiple API requests' do
        # split into 89 day first range, with correct start and end time
        readings
        expect(stub).to have_received(:readings).with(
          meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, start_date,
          DateTime.new(2023, 3, 31, 0, 0)
        )
        # split into final 11 day range with correct start and end time
        expect(stub).to have_received(:readings).with(
          meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION,
          DateTime.new(2023, 3, 31, 0, 30), end_date
        )
      end
    end

    context 'with no device readings' do
      let(:response) {  { 'devices' => [] } }

      it 'returns empty results' do
        expect(readings[meter.meter_type][:readings]).to be_empty
      end
    end

    context 'with successful results' do
      # Match dates in fixture
      let(:start_date) { Date.new(2012, 4, 27) }
      let(:end_date) { Date.new(2012, 4, 28) }
      let(:response) { JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json')) }

      def fixture_readings
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.214, 0.158, 0.064,
         0.062, 0.1, 0.096, 0.061, 0.097, 0.102, 0.129, 0.1, 0.101, 0.123, 0.245, 0.109, 0.018, 0.058, 0.057, 0.019,
         0.03, 0.107, 0.058, 0.025, 0.019, 0.1, 0.219, 0.132, 0.091, 0.105, 0.11, 0.09]
      end

      it 'extracts the readings' do
        readings_by_day = readings[meter.meter_type][:readings]
        # Match readings from fixture
        expect(readings_by_day[start_date].kwh_data_x48).to eq(fixture_readings)
      end

      context 'when returned readings are in m3' do
        let(:response) { super().merge('unit' => 'm3') }
        let(:meter) { create(:gas_meter) }

        it 'converts to kWh' do
          adjusted = fixture_readings.map { |r| r.nil? ? nil : (r * 11.1).round(2) }
          readings_by_day = readings[meter.meter_type][:readings]
          expect(readings_by_day[start_date].kwh_data_x48.map { |f| f&.round(2) }).to eq(adjusted)
        end

        it 'does not convert bad values' do
          bad_value = Aggregation::ValidateAmrData::BadValues::GAS.first.first
          response['devices'][0]['values'][0]['primaryValue'] = bad_value
          expect(readings[meter.meter_type][:readings][start_date].kwh_halfhour(17)).to eq(bad_value)
        end
      end

      context 'when there are multiple devices' do
        let(:response) do
          response = super()
          device = response['devices'][0].deep_dup
          device['values'][-2]['primaryValue'] = 0.5
          response['devices'] << device
          response
        end

        it 'combined readings from all devices' do
          readings_by_day = readings[meter.meter_type][:readings]
          # Match readings from fixture
          expect(readings_by_day[start_date].kwh_data_x48).to eq(fixture_readings.tap { |a| a[-2] = 0.5 })
        end

        it 'logs to Rollbar' do
          allow(Rollbar).to receive(:warning)
          readings
          expect(Rollbar).to have_received(:warning).with(anything, meter: meter.mpan_mprn, school: meter.school.name)
        end
      end
    end
  end
end

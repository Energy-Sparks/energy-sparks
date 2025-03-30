require 'rails_helper'

describe Amr::N3rgyDownloader do
  subject(:service) do
    described_class.new(meter: meter, start_date: start_date, end_date: end_date)
  end

  let(:meter)     { create(:electricity_meter) }
  let(:config)    { create(:amr_data_feed_config)}
  let(:end_date)  { Time.zone.today }
  let(:start_date) { end_date - 1 }

  describe '#readings' do
    let(:stub) { double('data-api-client') }

    before do
      allow(DataFeeds::N3rgy::DataApiClient).to receive(:production_client).and_return(stub)
    end

    context 'with a period of more than 90 days' do
      let(:start_date) { DateTime.new(2023, 1, 1, 0, 30) }
      let(:end_date) { DateTime.new(2023, 4, 11, 0, 0) } # 100 days ahead
      let(:response) do
        {
          'devices' => [{ 'values' => [] }]
        }
      end

      it 'makes multiple API requests' do
        allow(stub).to receive(:readings).at_least(:twice).with(meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, anything, anything).and_return(response)

        # split into 89 day first range, with correct start and end time
        expect(stub).to receive(:readings).with(meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, start_date, DateTime.new(2023, 3, 31, 0, 0))

        # split into final 11 day range with correct start and end time
        expect(stub).to receive(:readings).with(meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, DateTime.new(2023, 3, 31, 0, 30), end_date)
        service.readings
      end
    end

    context 'with no device readings' do
      let(:response) do
        {
          'devices' => []
        }
      end

      it 'returns empty results' do
        allow(stub).to receive(:readings).with(meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, anything, anything).and_return(response)
        readings = service.readings
        expect(readings[meter.meter_type][:readings]).to be_empty
      end
    end

    context 'with successful results' do
      subject(:readings) { service.readings }

      # Match dates in fixture
      let(:start_date) { Date.new(2012, 4, 27)}
      let(:end_date) { Date.new(2012, 4, 28)}

      let(:response) { JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json')) }

      let(:fixture_readings) do
        [nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.214, 0.158, 0.064, 0.062, 0.1, 0.096, 0.061, 0.097, 0.102, 0.129, 0.1, 0.101, 0.123, 0.245, 0.109, 0.018, 0.058, 0.057, 0.019, 0.03, 0.107, 0.058, 0.025, 0.019, 0.1, 0.219, 0.132, 0.091, 0.105, 0.11, 0.09]
      end

      before do
        allow(stub).to receive(:readings).with(meter.mpan_mprn, meter.fuel_type.to_s, DataFeeds::N3rgy::DataApiClient::READING_TYPE_CONSUMPTION, anything, anything).and_return(response.with_indifferent_access)
      end

      it 'extracts the readings' do
        readings_by_day = readings[meter.meter_type][:readings]
        # Match readings from fixture
        expect(readings_by_day[start_date].kwh_data_x48).to eq(fixture_readings)
      end

      context 'when returned readings are in m3' do
        let(:response) do
          original = JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json'))
          original['unit'] = 'm3'
          original
        end

        it 'converts to kWh' do
          adjusted = fixture_readings.map { |r| r.nil? ? nil : (r * 11.1).round(2) }
          readings_by_day = readings[meter.meter_type][:readings]
          expect(readings_by_day[start_date].kwh_data_x48.map { |f| f&.round(2) }).to eq(adjusted)
        end
      end

      context 'when there are multiple devices' do
        let(:response) do
          original = JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json'))
          original['devices'] << original['devices'][0] # duplicate the entries
          original
        end

        it 'still extract readings from first device' do
          readings_by_day = readings[meter.meter_type][:readings]
          # Match readings from fixture
          expect(readings_by_day[start_date].kwh_data_x48).to eq(fixture_readings)
        end

        it 'logs to Rollbar' do
          expect(Rollbar).to receive(:warning).with(anything, meter: meter.mpan_mprn, school: meter.school.name)
          readings
        end
      end
    end
  end
end

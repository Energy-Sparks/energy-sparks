# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::MeteoStat do
  let(:latitude)    { 123 }
  let(:longitude)   { 456 }

  describe 'historic_temperatures' do
    # this includes interpolated data
    let(:expected_historic_temperatures) do
      {
        temperatures: {
          Date.parse('2022-02-05') => [4.3, 4.15, 4.0, 3.85, 3.7, 3.65, 3.6, 3.65, 3.7, 3.75, 3.8, 3.8, 3.8, 3.95, 4.1,
                                       4.45, 4.8, 5.35, 5.9, 6.55, 7.2, 7.5, 7.8, 8.1, 8.4, 8.55, 8.7, 8.85, 9.0, 9.05, 9.1, 9.05, 9.0, 9.05, 9.1, 9.1, 9.1, 9.15, 9.2, 9.1, 9.0, 9.05, 9.1, 9.1, 9.1, 9.1, 9.1, 9.1],
          Date.parse('20220206') => [9.1, 9.2, 9.3, 9.35, 9.4, 9.45, 9.5, 9.5, 9.5, 9.5, 9.5, 9.55, 9.6, 9.55, 9.5,
                                     9.45, 9.4, 9.3, 9.2, 9.1, 9.0, 9.1, 9.2, 9.3, 9.4, 9.35, 9.3, 9.3, 9.3, 9.25, 9.2, 9.25, 9.3, 9.0, 8.7, 8.6, 8.5, 8.2, 7.9, 7.7, 7.5, 7.4, 7.3, 7.1, 6.9, 6.8, 6.7, 6.7]
        },
        missing: []
      }
    end

    let(:start_date)  { Date.parse('20220205') }
    let(:end_date)    { Date.parse('20220206') }
    let(:temperature_json) { JSON.parse(File.read('spec/fixtures/meteostat/historic_temperatures.json')) }

    describe 'returns expected temperature data' do
      let(:api_call_count) { 1 }

      it 'returns expected temperatures' do
        expect_any_instance_of(DataFeeds::MeteoStatApi).to \
          receive(:historic_temperatures).exactly(api_call_count).times.and_return(temperature_json)
        expect(described_class.new.historic_temperatures(latitude, longitude, start_date,
                                                         end_date)).to eq(expected_historic_temperatures)
      end
    end

    describe 'for longer date ranges' do
      let(:api_call_count) { 1 }
      let(:start_date)  { Date.parse('20220201') }
      let(:end_date)    { Date.parse('20220206') }

      it 'requests 30 days at a time for 6 day span but shows 24 hours * 4 days missing' do
        expect_any_instance_of(DataFeeds::MeteoStatApi).to \
          receive(:historic_temperatures).exactly(api_call_count).times.and_return(temperature_json)
        data = described_class.new.historic_temperatures(latitude, longitude, start_date, end_date)
        expect(data[:missing].count).to eq(24 * 4)
      end
    end
  end

  describe 'nearest_weather_stations' do
    describe 'when stations exist' do
      let(:expected_nearest_weather_stations) do
        [
          { id: '03354', name: 'Nottingham Weather Centre', latitude: 53.0, longitude: -1.25, elevation: 117,
            distance: 0.0 },
          { id: 'EGXN0', name: 'Newton / Saxondale', latitude: 52.9667, longitude: -0.9833, elevation: 55,
            distance: 18_234.0 }
        ]
      end

      let(:nearest_json) { JSON.parse(File.read('spec/fixtures/meteostat/nearby_stations.json')) }
      let(:find_1_json)        { JSON.parse(File.read('spec/fixtures/meteostat/find_station_1.json')) }
      let(:find_2_json)        { JSON.parse(File.read('spec/fixtures/meteostat/find_station_2.json')) }

      before do
        allow_any_instance_of(DataFeeds::MeteoStatApi).to receive(:nearby_stations).and_return(nearest_json)
        allow_any_instance_of(DataFeeds::MeteoStatApi).to receive(:find_station).with('03354').and_return(find_1_json)
        allow_any_instance_of(DataFeeds::MeteoStatApi).to receive(:find_station).with('EGXN0').and_return(find_2_json)
      end

      it 'returns expected stations' do
        expect(described_class.new.nearest_weather_stations(latitude, longitude,
                                                            2)).to eq(expected_nearest_weather_stations)
      end
    end

    describe 'when no stations found' do
      before do
        allow_any_instance_of(DataFeeds::MeteoStatApi).to receive(:nearby_stations).and_return({})
      end

      it 'handles it' do
        expect(described_class.new.nearest_weather_stations(latitude, longitude, 2)).to eq([])
      end
    end
  end
end

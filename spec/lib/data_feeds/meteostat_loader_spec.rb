require 'rails_helper'

module DataFeeds
  describe MeteostatLoader do
    let(:interface) { double("meteostat_interface")}
    let!(:weather_station)                  { create(:weather_station) }
    let!(:inactive_station)                 { create(:weather_station, active: false) }
    let(:start_date)                        { Date.parse('2021-01-01') }
    let(:bad_temperature_readings)          { [10.0] }
    let(:good_temperature_readings)         { Array.new(48, 10.0) }
    let(:good_warmer_temperature_readings)  { Array.new(48, 15.0) }
    let(:weather_observation)               { create(:weather_observation, weather_station: weather_station, reading_date: start_date, temperature_celsius_x48: good_temperature_readings)}

    context "when running an import" do
      it "only processes active meteostat stations" do
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date => good_temperature_readings }, missing: nil }
        end
        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import }.to change { WeatherObservation.count}.from(0).to(1)
      end

      it "counts number of stations processed" do
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date => good_temperature_readings }, missing: nil }
        end
        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import }.to change { WeatherObservation.count }.from(0).to(1)
        expect(loader.stations_processed).to eql 1
      end
    end
    context "with good data" do
      it "inserts a record per day" do
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date => good_temperature_readings }, missing: nil }
        end
        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import_station(weather_station) }.to change { WeatherObservation.count}.from(0).to(1)
        expect(WeatherObservation.first.weather_station).to eq weather_station
        expect(WeatherObservation.first.temperature_celsius_x48).to eq good_temperature_readings
        expect(loader.insert_count).to eql 1
        expect(loader.update_count).to eql 0
        expect(loader.stations_processed).to eql 1
      end

      it "updates existing records" do
        weather_observation
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date => good_warmer_temperature_readings }, missing: nil }
        end
        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import_station(weather_station) }.to_not change { WeatherObservation.count}
        expect(WeatherObservation.first.temperature_celsius_x48).to eq good_warmer_temperature_readings
        expect(loader.insert_count).to eql 0
        expect(loader.update_count).to eql 1
      end
    end

    context "with bad data" do
      it "does not insert readings" do
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date: bad_temperature_readings }, missing: nil }
        end

        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import_station(weather_station) }.to_not change { WeatherObservation.count }
      end
    end

    context "working with the API" do
      it "passes the right parameters" do
        allow(interface).to receive(:historic_temperatures) do
          { temperatures: { start_date => good_temperature_readings }, missing: nil }
        end
        expect(interface).to receive(:historic_temperatures).with(
          weather_station.latitude, weather_station.longitude, start_date, start_date + 1.day)
        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        loader.import_station(weather_station)
      end

      it "does not fail on error" do
        allow(interface).to receive(:historic_temperatures).and_raise("an error") do
          raise NoMethodError, "raised a test error"
        end

        loader = MeteostatLoader.new(start_date, start_date + 1.day, interface)
        expect { loader.import_station(weather_station) }.to_not raise_error
      end
    end
  end
end

require 'rails_helper'

module DataFeeds
  describe DarkSkyTemperatureLoader do

    let(:dark_sky_api_interface)            { double("dark_sky_api_interface") }
    let(:good_temperature_readings)         { Array.new(48, 10.0) }
    let(:good_warmer_temperature_readings)  { Array.new(48, 15.0) }
    let(:bad_temperature_readings)          { [10.0] }
    let(:start_date)                        { Date.parse('2019-05-01') }
    let!(:dark_sky_area)                    { create(:dark_sky_area, title: "Can't see anything") }

    describe 'with good data' do
      it 'creates a record per day and updates if a record exists' do
        allow(dark_sky_api_interface).to receive(:historic_temperatures) do
          [nil, { start_date => good_temperature_readings }, 0, 0]
        end

        dstl = DarkSkyTemperatureLoader.new(start_date, start_date + 1.day, dark_sky_api_interface)
        expect { dstl.import }.to change { DarkSkyTemperatureReading.count }.from(0).to(1)
        expect(DarkSkyTemperatureReading.first.temperature_celsius_x48).to eq good_temperature_readings

        allow(dark_sky_api_interface).to receive(:historic_temperatures) do
          [nil, { start_date => good_warmer_temperature_readings }, 0, 0]
        end

        dstl = DarkSkyTemperatureLoader.new(start_date, start_date + 1.day, dark_sky_api_interface)
        expect { dstl.import }.to_not change { DarkSkyTemperatureReading.count }
        expect(DarkSkyTemperatureReading.first.temperature_celsius_x48).to eq good_warmer_temperature_readings
      end
    end

    it 'rejects duff data  record per day' do
      allow(dark_sky_api_interface).to receive(:historic_temperatures) do
        [nil, { start_date => bad_temperature_readings }, 0, 0]
      end

      dstl = DarkSkyTemperatureLoader.new(start_date, start_date + 1.day, dark_sky_api_interface)
      expect { dstl.import }.to_not change { DarkSkyTemperatureReading.count }
    end
  end
end

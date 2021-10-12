require 'rails_helper'

module DataFeeds
  describe SolarPvTuosLoader do

    let(:solar_pv_tuos_interface)         { double("solar_pv_tuos_interface") }
    let(:good_generation_readings)        { Array.new(48, 10.0) }
    let(:good_sunny_generation_readings)  { Array.new(48, 15.0) }
    let(:bad_generation_readings)         { [10.0] }
    let(:latitude)                        { 51.39 }
    let(:longitude)                       { -2.37 }
    let(:distance_km)                     { 123.45 }
    let(:start_date)                      { Date.parse('2019-05-01') }
    let!(:solar_pv_tuos_area)             { create(:solar_pv_tuos_area, title: "The sun has got his hat on") }

    before(:each) do
      allow(solar_pv_tuos_interface).to receive(:find_nearest_areas) do
        [{ gsp_id: 123, gsp_name: 'Here', latitude: latitude, longitude: longitude, distance_km: distance_km }]
      end
    end

    describe 'with good data' do
      it 'creates a record per day and updates if a record exists' do
        allow(solar_pv_tuos_interface).to receive(:historic_solar_pv_data) do
          [ { start_date => good_generation_readings }, nil, nil ]
        end

        spvtl = SolarPvTuosLoader.new(start_date, start_date + 1.day, solar_pv_tuos_interface)
        expect { spvtl.import }.to change { SolarPvTuosReading.count }.from(0).to(1)
        expect(SolarPvTuosReading.first.generation_mw_x48).to eq good_generation_readings

        allow(solar_pv_tuos_interface).to receive(:historic_solar_pv_data) do
          [ { start_date => good_sunny_generation_readings }, nil, nil ]
        end

        spvtl = SolarPvTuosLoader.new(start_date, start_date + 1.day, solar_pv_tuos_interface)
        expect { spvtl.import }.to_not change { SolarPvTuosReading.count }
        expect(SolarPvTuosReading.first.generation_mw_x48).to eq good_sunny_generation_readings
      end
    end

    it 'rejects duff data  record per day' do
      allow(solar_pv_tuos_interface).to receive(:historic_solar_pv_data) do
        [ { start_date => bad_generation_readings }, nil, nil ]
      end

      spvtl = SolarPvTuosLoader.new(start_date, start_date + 1.day, solar_pv_tuos_interface)
      expect { spvtl.import }.to_not change { SolarPvTuosReading.count }
    end
  end
end

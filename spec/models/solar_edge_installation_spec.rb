require 'rails_helper'


describe SolarEdgeInstallation do
  subject(:solar_edge_installation) { create(:solar_edge_installation) }

  describe '#electricity_meter' do
    let(:meter) { solar_edge_installation.electricity_meter }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(meter).to be_nil
      end
    end

    context 'when there is only an electricity meter' do
      subject(:solar_edge_installation) { create(:solar_edge_installation, :with_electricity_meter) }

      it 'returns the meter' do
        expect(meter).to eq(solar_edge_installation.meters.first)
      end
    end

    context 'when all meters are present' do
      subject(:solar_edge_installation) { create(:solar_edge_installation_with_meters_and_validated_readings) }

      it 'returns the meter' do
        expect(meter).to eq(Meter.electricity.first)
      end
    end
  end

  describe '#latest_electricity_reading' do
    let(:latest_electricity_reading) { solar_edge_installation.latest_electricity_reading }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(latest_electricity_reading).to be_nil
      end
    end

    context 'when there is an electricity meter' do
      context 'with no readings' do
        let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 60000000000000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation) }

        it 'returns nil' do
          expect(latest_electricity_reading).to be_nil
        end
      end

      context 'with readings' do
        let!(:electricity_meter) { create(:electricity_meter_with_reading, mpan_mprn: 60000000000000 + solar_edge_installation.mpan.to_i, pseudo: true, solar_edge_installation: solar_edge_installation) }

        it 'returns the latest date' do
          expect(latest_electricity_reading).to eq(Date.parse(AmrDataFeedReading.first.reading_date))
        end
      end
    end
  end
end

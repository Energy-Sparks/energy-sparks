require 'rails_helper'

describe LowCarbonHubInstallation do
  subject(:low_carbon_hub_installation) { create(:low_carbon_hub_installation) }

  describe '#electricity_meter' do
    let(:meter) { low_carbon_hub_installation.electricity_meter }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(meter).to be_nil
      end
    end

    context 'when there is only an electricity meter' do
      subject(:low_carbon_hub_installation) { create(:low_carbon_hub_installation, :with_electricity_meter) }

      it 'returns the meter' do
        expect(meter).to eq(low_carbon_hub_installation.meters.first)
      end
    end

    context 'when all meters are present' do
      subject(:low_carbon_hub_installation) { create(:low_carbon_hub_installation_with_meters_and_validated_readings) }

      it 'returns the meter' do
        expect(meter).to eq(Meter.electricity.first)
      end
    end
  end

  describe '#latest_electricity_reading' do
    let(:latest_electricity_reading) { low_carbon_hub_installation.latest_electricity_reading }

    context 'when there is no meter' do
      it 'returns nil' do
        expect(latest_electricity_reading).to be_nil
      end
    end

    context 'when there is an electricity meter' do
      context 'with no readings' do
        let!(:electricity_meter) { create(:electricity_meter, mpan_mprn: 60000000000000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation) }

        it 'returns nil' do
          expect(latest_electricity_reading).to be_nil
        end
      end

      context 'with readings' do
        let!(:electricity_meter) { create(:electricity_meter_with_reading, mpan_mprn: 60000000000000 + low_carbon_hub_installation.rbee_meter_id.to_i, pseudo: true, low_carbon_hub_installation: low_carbon_hub_installation) }

        it 'returns the latest date' do
          expect(latest_electricity_reading).to eq(Date.parse(AmrDataFeedReading.first.reading_date))
        end
      end
    end
  end
end

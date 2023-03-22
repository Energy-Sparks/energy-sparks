require 'rails_helper'

describe TariffPrice do

  let(:meter) { create(:electricity_meter, dcc_meter: true) }

  context '#tariff_type' do
    context 'with flat rate' do
      let!(:price) { create(:tariff_price, :with_flat_rate, meter: meter) }
      it 'returns correct type' do
        expect(price.tariff_type).to eq(:flat)
      end
    end
    context 'with differential rate' do
      let!(:price) { create(:tariff_price, :with_differential_tariff, meter: meter) }
      it 'returns correct type' do
        expect(price.tariff_type).to eq(:differential)
      end
    end
    context 'with differential tiered rate' do
      let!(:price) { create(:tariff_price, :with_differential_tiered_tariff, meter: meter) }
      it 'returns correct type' do
        expect(price.tariff_type).to eq(:differential_tiered)
      end
    end
  end
end

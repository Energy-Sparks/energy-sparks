require 'rails_helper'

describe 'TariffPrice' do
  let(:meter) { create(:electricity_meter) }

  describe '#delete_duplicates_for_meter!' do
    let(:prices)   { Array.new(48, 0.3) }
    let!(:first)   { create(:tariff_price, :with_flat_rate, meter: meter, tariff_date: Date.new(2023, 1, 1), flat_rate: prices) }
    let!(:second)  { create(:tariff_price, :with_flat_rate, meter: meter, tariff_date: Date.new(2023, 1, 2), flat_rate: Array.new(48, 0.4)) }

    it 'doesnt delete if not duplicates' do
      expect { TariffPrice.delete_duplicates_for_meter!(meter) }.not_to(change {TariffPrice.count})
    end

    context 'with duplicates on following day' do
      let!(:second) { create(:tariff_price, :with_flat_rate, meter: meter, tariff_date: Date.new(2023, 1, 2), flat_rate: prices) }

      it 'deletes duplicates' do
        expect { TariffPrice.delete_duplicates_for_meter!(meter) }.to change {TariffPrice.count}.by(-1)
      end
    end

    context 'with many duplicates' do
      let!(:duplicates) { create_list(:tariff_price, 10, :with_flat_rate, meter: meter, flat_rate: prices) }

      it 'deletes duplicates' do
        #should remove all but one of the 10
        expect { TariffPrice.delete_duplicates_for_meter!(meter) }.to change {TariffPrice.count}.by(-9)
      end
    end

    context 'with duplicates on different days' do
      let!(:third) { create(:tariff_price, :with_flat_rate, meter: meter, tariff_date: Date.new(2023, 1, 3), flat_rate: prices) }

      it 'does not delete duplicates' do
        expect { TariffPrice.delete_duplicates_for_meter!(meter) }.not_to(change {TariffPrice.count})
      end
    end
  end
end

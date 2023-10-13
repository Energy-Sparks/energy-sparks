require 'rails_helper'

describe TariffStandingCharge do
  let(:meter) { create(:electricity_meter) }
  let(:tariff_standing_charge) { create(:tariff_standing_charge) }
  let(:tariff_import_log) { create(:tariff_import_log) }
  let(:start_date) { Date.parse('2021-01-01') }
  let(:value) { 0.123 }

  before :each do
    @tariff_standing_charge = TariffStandingCharge.create!(start_date: start_date, value: value, tariff_import_log: tariff_import_log, meter: meter)
  end

  it 'returns values as Float not BigDecimal' do
    @tariff_standing_charge.reload
    expect(@tariff_standing_charge.value).to eq(0.123)
    expect(@tariff_standing_charge.value.class).to eq(Float)
  end

  describe '#delete_duplicates_for_meter!' do
    let(:charge)   { 0.1 }
    let!(:first)   { create(:tariff_standing_charge, meter: meter, start_date: Date.new(2023, 1, 1), value: charge) }
    let!(:second)  { create(:tariff_standing_charge, meter: meter, start_date: Date.new(2023, 1, 2), value: 0.3) }

    it 'doesnt delete if not duplicates' do
      expect { TariffStandingCharge.delete_duplicates_for_meter!(meter) }.not_to(change {TariffStandingCharge.count})
    end

    context 'with duplicates on following day' do
      let!(:second) { create(:tariff_standing_charge, meter: meter, start_date: Date.new(2023, 1, 2), value: charge) }
      it 'deletes duplicates' do
        expect { TariffStandingCharge.delete_duplicates_for_meter!(meter) }.to change {TariffStandingCharge.count}.by(-1)
      end
    end

    context 'with many duplicates' do
      let!(:duplicates) { create_list(:tariff_standing_charge, 10, meter: meter, value: charge) }
      it 'deletes duplicates' do
        #should remove all but one of the 10
        expect { TariffStandingCharge.delete_duplicates_for_meter!(meter) }.to change {TariffStandingCharge.count}.by(-9)
      end
    end

    context 'with duplicates on different days' do
      let!(:third) { create(:tariff_standing_charge, meter: meter, start_date: Date.new(2023, 1, 3), value: charge) }
      it 'does not delete duplicates' do
        expect { TariffStandingCharge.delete_duplicates_for_meter!(meter) }.not_to(change {TariffStandingCharge.count})
      end
    end
  end
end

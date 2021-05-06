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
end

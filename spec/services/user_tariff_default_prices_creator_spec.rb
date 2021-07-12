
require 'rails_helper'

describe UserTariffDefaultPricesCreator do

  context 'for flat rate tariffs' do
    let(:user_tariff) { create(:user_tariff, flat_rate: true) }

    it 'does not add prices' do
      UserTariffDefaultPricesCreator.new(user_tariff).process
      user_tariff.reload
      expect(user_tariff.user_tariff_prices.count).to eq(0)
    end
  end

  context 'for differential rate tariffs' do
    let(:user_tariff) { create(:user_tariff, flat_rate: false) }

    it 'handles missing meters' do
      UserTariffDefaultPricesCreator.new(user_tariff).process
      user_tariff.reload
      expect(user_tariff.user_tariff_prices.count).to eq(0)
    end

    it 'adds prices with default time ranges' do
      user_tariff.meters << create(:gas_meter)
      UserTariffDefaultPricesCreator.new(user_tariff).process
      user_tariff.reload
      expect(user_tariff.user_tariff_prices.count).to eq(2)
      expect(user_tariff.user_tariff_prices.first.start_time.to_s(:time)).to eq('00:00')
      expect(user_tariff.user_tariff_prices.first.end_time.to_s(:time)).to eq('07:00')
      expect(user_tariff.user_tariff_prices.first.description).to eq('Night rate')
      expect(user_tariff.user_tariff_prices.last.start_time.to_s(:time)).to eq('07:00')
      expect(user_tariff.user_tariff_prices.last.end_time.to_s(:time)).to eq('00:00')
      expect(user_tariff.user_tariff_prices.last.description).to eq('Day rate')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Baseload::SeasonalBaseloadService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:meter)          { @acme_academy.aggregated_electricity_meters }
  let(:service)        { described_class.new(meter, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#seasonal_variation' do
    it 'calculates the variation' do
      seasonal_variation = service.seasonal_variation
      expect(seasonal_variation.winter_kw).to be_within(0.01).of(31.76)
      expect(seasonal_variation.summer_kw).to be_within(0.01).of(18.305)
      expect(seasonal_variation.percentage).to be_within(0.01).of(0.735)
    end
  end

  describe '#estimated_costs' do
    it 'calculates the costs' do
      costs = service.estimated_costs
      expect(costs.kwh).to be_within(0.01).of(92_735.88)
      expect(costs.£).to be_within(0.01).of(10_853.27)
      expect(costs.co2).to be_within(0.01).of(15_493.97)
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
      end
    end

    context 'when theres is limited data' do
      # acme academy has data starting in 2019-01-13
      let(:asof_date) { Date.new(2019, 6, 1) }

      it 'returns false' do
        expect(service.enough_data?).to be false
      end
    end
  end
end

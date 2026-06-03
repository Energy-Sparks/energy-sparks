# frozen_string_literal: true

require 'rails_helper'

describe Baseload::IntraweekBaseloadService, type: :service do
  let(:asof_date)      { Date.new(2022, 2, 1) }
  let(:meter)          { @acme_academy.aggregated_electricity_meters }
  let(:service)        { described_class.new(meter, asof_date) }

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#intraweek_variation' do
    it 'calculates the variation' do
      intraweek_variation = service.intraweek_variation
      expect(intraweek_variation.min_day).to eq 6
      expect(intraweek_variation.max_day).to eq 1
      expect(intraweek_variation.min_day_kw).to be_within(0.01).of(21.62)
      expect(intraweek_variation.max_day_kw).to be_within(0.01).of(23.57)
      expect(intraweek_variation.percent_intraday_variation).to be_within(0.01).of(0.09)
      expect(intraweek_variation.annual_cost_kwh).to be_within(0.01).of(11_051.89)
    end
  end

  describe '#estimated_costs' do
    it 'calculates the costs' do
      costs = service.estimated_costs
      expect(costs.kwh).to be_within(0.01).of(11_051.89)
      expect(costs.co2).to be_within(0.01).of(1846.51)
      expect(costs.£).to be_within(0.01).of(1293.45)
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

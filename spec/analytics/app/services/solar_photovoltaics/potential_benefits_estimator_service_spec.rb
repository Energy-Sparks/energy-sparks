# frozen_string_literal: true

require 'rails_helper'

describe SolarPhotovoltaics::PotentialBenefitsEstimatorService, type: :service do
  let(:service) do
    described_class.new(meter_collection: @acme_academy, asof_date: Date.parse('2020-12-31'))
  end

  # using before(:all) here to avoid slow loading of YAML and then
  # running the aggregation code for each test.
  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  describe '#enough_data?' do
    it 'returns true if one years worth of data is available' do
      expect(service.enough_data?).to eq(true)
    end
  end

  describe '#create_model' do
    let(:model)     { service.create_model }
    let(:scenarios) { model.scenarios }

    it 'calculates the potential benefits over a geometric sequence of capacity kWp' do
      expect(model.optimum_kwp).to be_within(0.01).of(75.5)
      expect(model.optimum_payback_years).to be_within(0.01).of(8.11)
      expect(model.optimum_mains_reduction_percent).to be_within(0.01).of(0.13)
      expect(model.scenarios.size).to eq 9

      expect(scenarios[0].kwp).to eq(1)
      expect(scenarios[0].panels).to eq(3)
      expect(scenarios[0].area).to eq(4)
      expect(scenarios[0].solar_consumed_onsite_kwh).to be_within(0.01).of(852.13)
      expect(scenarios[0].exported_kwh).to be_within(0.01).of(0.0)
      expect(scenarios[0].solar_pv_output_kwh).to be_within(0.01).of(852.13)
      expect(scenarios[0].reduction_in_mains_percent * 100).to be_within(0.01).of(0.197)
      expect(scenarios[0].mains_savings_£).to be_within(0.01).of(109.87)
      expect(scenarios[0].solar_pv_output_co2).to be_within(0.01).of(142.37)
      expect(scenarios[0].capital_cost_£).to be_within(0.01).of(1584.0)
      expect(scenarios[0].payback_years).to be_within(0.01).of(14.41)

      expect(scenarios[8].kwp).to eq(128)
    end
  end
end

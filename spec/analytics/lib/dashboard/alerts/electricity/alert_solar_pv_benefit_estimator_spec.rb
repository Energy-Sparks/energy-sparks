# frozen_string_literal: true

require 'rails_helper'

describe AlertSolarPVBenefitEstimator do
  subject(:alert) { described_class.new(meter_collection) }

  let(:asof_date) { Date.new(2025, 12, 31) }
  let(:meter_collection) do
    build(:meter_collection, :with_aggregate_meter, fuel_type: :electricity,
                                                    start_date: asof_date - 364, end_date: asof_date)
  end

  context 'when school does not have solar' do
    let(:service) do
      instance_double(SolarPhotovoltaics::PotentialBenefitsEstimatorService,
                      enough_data?: true, calculate_optimum_scenario: optimum_scenario)
    end
    let(:optimum_scenario) do
      {
        kwp: 10.0,
        payback_years: 8.0,
        reduction_in_mains_percent: 0.4,
        total_annual_saving_£: 1200.0,
        reduction_in_mains_kwh: 5000.0,
        total_annual_saving_co2: 900.0,
        capital_cost_£: 9600.0
      }
    end

    before do
      allow(SolarPhotovoltaics::PotentialBenefitsEstimatorService)
        .to receive(:new).with(meter_collection:, asof_date:).and_return(service)
      alert.analyse(asof_date)
    end

    it 'creates variables based on the benefit estimate' do
      expect(alert.optimum_kwp).to eq(optimum_scenario[:kwp])
      expect(alert.optimum_payback_years).to eq(optimum_scenario[:payback_years])
      expect(alert.optimum_mains_reduction_percent).to eq(optimum_scenario[:reduction_in_mains_percent])
      expect(alert.one_year_saving_£current).to eq(optimum_scenario[:total_annual_saving_£]) # rubocop:disable Naming/AsciiIdentifiers
      expect(alert.one_year_saving_kwh).to eq(optimum_scenario[:reduction_in_mains_kwh])
      expect(alert.one_year_saving_co2).to eq(optimum_scenario[:total_annual_saving_co2])
      expect(alert.one_year_saving_£).to eq(Range.new(optimum_scenario[:total_annual_saving_£], # rubocop:disable Naming/AsciiIdentifiers
                                                      optimum_scenario[:total_annual_saving_£]))
      expect(alert.capital_cost).to eq(Range.new(optimum_scenario[:capital_cost_£], optimum_scenario[:capital_cost_£]))
    end
  end
end

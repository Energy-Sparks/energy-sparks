# frozen_string_literal: true

require 'rails_helper'

describe AlertSolarPVBenefitEstimator do
  subject(:alert) { described_class.new(meter_collection) }

  # using fixed generation and consumption to simplify calculating expected values
  let(:solar_generation_x48) { [*([0.0] * 10), *([0.25] * 10), *([0.5] * 8), *([0.25] * 10), *([0.0] * 10)] }
  let(:consumption_x48) { [*([0.1] * 10), *([0.005] * 10), *([0.4] * 8), *([0.25] * 10), *([0.01] * 10)] }

  include_context 'with an aggregated meter with tariffs and school times' do
    let(:amr_start_date)  { Date.new(2024, 1, 1) }
    let(:amr_end_date)    { Date.new(2025, 12, 31) }
    let(:days_solar_pv_yield) { solar_generation_x48 }

    let(:amr_data) do
      build(:amr_data, :with_date_range, :with_grid_carbon_intensity,
            grid_carbon_intensity: grid_carbon_intensity,
            start_date: amr_start_date,
            end_date: amr_end_date,
            kwh_data_x48: consumption_x48)
    end
  end

  context 'when school does not have solar' do
    let(:service) do
      SolarPhotovoltaics::PotentialBenefitsEstimatorService.new(meter_collection:,
                                                                asof_date: Date.new(2025, 12, 31))
    end

    before do
      alert.analyse(Date.new(2025, 12, 31))
    end

    it 'creates variables based on the benefit estimate' do
      optimum_scenario = service.calculate_optimum_scenario

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

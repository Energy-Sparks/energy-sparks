# frozen_string_literal: true

require 'rails_helper'

describe SolarPhotovoltaics::PotentialBenefitsEstimatorService, type: :service do
  subject(:service) { described_class.new(meter_collection:, asof_date: Date.new(2025, 12, 31)) }

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

  describe '#calculate_optimum_scenario' do
    subject(:scenario) { service.calculate_optimum_scenario }

    it 'includes the expected values' do
      expect(scenario.keys).to match_array(%i[area
                                              capital_cost_£
                                              existing_annual_£
                                              existing_annual_kwh
                                              exported_kwh
                                              export_income_£
                                              kwp
                                              mains_savings_£
                                              new_mains_consumption_£
                                              new_mains_consumption_kwh
                                              panels
                                              payback_years
                                              reduction_in_mains_kwh
                                              reduction_in_mains_percent
                                              solar_consumed_onsite_kwh
                                              solar_pv_output_co2
                                              solar_pv_output_kwh
                                              total_annual_saving_£
                                              total_annual_saving_co2])
    end

    it 'produces a sensible scenario' do
      expect(scenario[:kwp]).to be_positive
      expect(scenario[:panels]).to be_positive
      expect(scenario[:area]).to be < meter_collection.floor_area * described_class::ESTIMATE_ROOF_AREA_SIZE
    end

    it 'produces correctly calculated metrics' do
      # true regardless of the underlying data
      expect(scenario[:new_mains_consumption_kwh] + scenario[:reduction_in_mains_kwh]).to
      be_within(0.01).of(scenario[:existing_annual_kwh])
      expect(scenario[:new_mains_consumption_kwh] + scenario[:solar_consumed_onsite_kwh]).to
      be_within(0.01).of(scenario[:existing_annual_kwh])
      expect(scenario[:mains_savings_£] + scenario[:export_income_£]).to
      be_within(0.01).of(scenario[:total_annual_saving_£])

      expect(scenario[:solar_pv_output_kwh] - scenario[:exported_kwh]).to
      be_within(0.01).of(scenario[:solar_consumed_onsite_kwh])

      expect(scenario[:exported_kwh] * BenchmarkMetrics.pricing.solar_export_price).to
      be_within(0.01).of(scenario[:export_income_£])

      # true because of the data setup in the shared context
      expect(scenario[:existing_annual_£]).to
      be_within(0.01).of(scenario[:existing_annual_kwh] * 0.1) # flat_rate
      expect(scenario[:new_mains_consumption_£]).to
      be_within(0.01).of(scenario[:new_mains_consumption_kwh] * 0.1) # flat_rate
      expect(scenario[:solar_pv_output_co2]).to
      be_within(0.01).of(scenario[:solar_pv_output_kwh] * 0.2) # carbon_intensity
    end
  end

  describe '#create_model' do
    subject(:model) { service.create_model }

    it 'produces scenarios' do
      expect(model.scenarios.count).to be_positive
      model.scenarios.each do |scenario|
        expect(scenario.to_h.keys).to match_array(%i[area
                                                     capital_cost_£
                                                     existing_annual_£
                                                     existing_annual_kwh
                                                     exported_kwh
                                                     export_income_£
                                                     kwp
                                                     mains_savings_£
                                                     new_mains_consumption_£
                                                     new_mains_consumption_kwh
                                                     panels
                                                     payback_years
                                                     reduction_in_mains_kwh
                                                     reduction_in_mains_percent
                                                     solar_consumed_onsite_kwh
                                                     solar_pv_output_co2
                                                     solar_pv_output_kwh
                                                     total_annual_saving_£
                                                     total_annual_saving_co2])
      end
    end
  end
end

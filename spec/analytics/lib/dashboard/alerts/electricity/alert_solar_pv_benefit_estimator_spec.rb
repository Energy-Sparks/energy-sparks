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
    let(:expected_alert_variables) do
      {
        optimum_kwp: '210 kWp',
        optimum_payback_years: '9 years',
        optimum_mains_reduction_percent: '84%',
        one_year_saving_£current: '£17,000',
        one_year_saving_kwh: '2,100 kWh',
        one_year_saving_£: '£17,000',
        one_year_saving_co2: '69,000 kg CO2',
        ten_year_saving_co2: '690,000 kg CO2',
        average_one_year_saving_£: '£17,000',
        average_ten_year_saving_£: '£170,000',
        ten_year_saving_£: '£170,000',
        payback_years: '',
        average_payback_years: '9 years',
        capital_cost: '£150,000',
        average_capital_cost: '£150,000'
      }
    end

    before do
      alert.analyse(Date.new(2025, 12, 31))
    end

    it 'calculates the expected variables' do
      expect(alert.text_template_variables.slice(*expected_alert_variables.keys)).to eq(expected_alert_variables)
    end
  end
end

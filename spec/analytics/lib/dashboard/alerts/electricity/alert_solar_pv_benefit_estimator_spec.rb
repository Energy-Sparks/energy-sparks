# frozen_string_literal: true

require 'rails_helper'

describe AlertSolarPVBenefitEstimator do
  subject(:alert) { described_class.new(school) }

  let(:school) { @acme_academy }

  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  context 'when school does not have solar' do
    let(:pricing) { BenchmarkMetrics.default_prices }

    let(:expected_alert_variables) do
      {
        optimum_kwp: '100 kWp',
        optimum_payback_years: '8 years',
        optimum_mains_reduction_percent: '16%',
        one_year_saving_£current: '£11,000',
        one_year_saving_kwh: '76,000 kWh',
        one_year_saving_£: '£11,000',
        one_year_saving_co2: '15,000 kg CO2',
        ten_year_saving_co2: '150,000 kg CO2',
        average_one_year_saving_£: '£11,000',
        average_ten_year_saving_£: '£110,000',
        ten_year_saving_£: '£110,000',
        payback_years: '',
        average_payback_years: '8 years',
        capital_cost: '£84,000',
        average_capital_cost: '£84,000'
      }
    end

    before do
      class_double('BenchmarkMetrics', pricing: pricing, default_prices: pricing).as_stubbed_const
      alert.analyse(Date.new(2022, 7, 12))
    end

    it 'calculates the expected variables' do
      expect(alert.text_template_variables.slice(*expected_alert_variables.keys)).to eq(expected_alert_variables)
    end

    context 'when pricing is updated' do
      let(:pricing) { OpenStruct.new(gas_price: 0.03, electricity_price: 0.15, solar_export_price: 0.1) }

      let(:expected_alert_variables) do
        {
          optimum_kwp: '250 kWp',
          optimum_payback_years: '7 years',
          optimum_mains_reduction_percent: '28%',
          one_year_saving_£current: '£26,000',
          one_year_saving_kwh: '130,000 kWh',
          one_year_saving_£: '£26,000',
          one_year_saving_co2: '35,000 kg CO2',
          ten_year_saving_co2: '350,000 kg CO2',
          average_one_year_saving_£: '£26,000',
          average_ten_year_saving_£: '£260,000',
          ten_year_saving_£: '£260,000',
          payback_years: '',
          average_payback_years: '7 years',
          capital_cost: '£170,000',
          average_capital_cost: '£170,000'
        }
      end

      it 'applies the export pricing' do
        expect(alert.text_template_variables.slice(*expected_alert_variables.keys)).to eq(expected_alert_variables)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe AlertSolarPVBenefitEstimator do
  let(:school) { @acme_academy }
  let(:alert) { described_class.new(school) }
  let(:default_pricing_template_variables) do
    {
      optimum_kwp: '100 kWp',
      optimum_payback_years: '8 years',
      optimum_mains_reduction_percent: '16%',
      one_year_saving_£current: '£11,000',
      relevance: 'relevant',
      analysis_date: '',
      status: '',
      rating: '5',
      term: '',
      max_asofdate: '',
      pupils: '961',
      floor_area: '5,900 m2',
      school_type: 'secondary',
      school_name: 'Acme Academy',
      school_activation_date: '',
      school_creation_date: '2020-10-08',
      urn: '123456',
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
      average_capital_cost: '£84,000',
      timescale: 'year',
      time_of_year_relevance: '5'
    }
  end

  before(:all) do
    @acme_academy = load_unvalidated_meter_collection(school: 'acme-academy')
  end

  it 'calculates the alert for a given asof date' do
    current_pricing = BenchmarkMetrics.default_prices
    class_double('BenchmarkMetrics', pricing: current_pricing, default_prices: current_pricing).as_stubbed_const
    alert.calculate(Date.new(2022, 7, 12))
    expect(BenchmarkMetrics.pricing).to eq(current_pricing)
    expect(alert.text_template_variables).to eq(default_pricing_template_variables)

    new_pricing = OpenStruct.new(gas_price: 0.06, electricity_price: 0.3, solar_export_price: 0.1)
    class_double('BenchmarkMetrics', pricing: new_pricing, default_prices: new_pricing).as_stubbed_const
    expect(BenchmarkMetrics.pricing).to eq(new_pricing)
    alert.calculate(Date.new(2022, 7, 12))
    expect(alert.text_template_variables).not_to eq(default_pricing_template_variables)
    expect(alert.text_template_variables[:one_year_saving_£current]).to eq('£26,000')
    expect(alert.text_template_variables[:one_year_saving_£]).to eq('£26,000')
    expect(alert.text_template_variables[:average_one_year_saving_£]).to eq('£26,000')
    expect(alert.text_template_variables[:average_ten_year_saving_£]).to eq('£260,000')
    expect(alert.text_template_variables[:ten_year_saving_£]).to eq('£260,000')
    expect(alert.text_template_variables[:capital_cost]).to eq('£170,000')
    expect(alert.text_template_variables[:average_capital_cost]).to eq('£170,000')
  end
end

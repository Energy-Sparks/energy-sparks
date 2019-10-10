require 'rails_helper'

module Schools
  describe 'GenerateGasDashboardChartConfiguration' do

    let!(:school)     { create(:school, :with_school_group) }
    let(:chart_data) { instance_double(ChartData) }

    before(:each) do
      allow(ChartData).to receive(:new).and_return(chart_data)
    end

    context 'gas dashboard chart configuration' do
      let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_and_gas, has_electricity: true, has_gas: true) }

      it 'returns the temperature compensated one if possible' do
        chart_data = instance_double(ChartData)
        allow(ChartData).to receive(:new).and_return(chart_data)
        allow(chart_data).to receive(:has_chart_data?).and_return(true)
        chart_type = GenerateGasDashboardChartConfiguration.new(school, nil, fuel_configuration).generate
        expect(chart_type).to eq Schools::Configuration::TEACHERS_GAS
      end

      it 'returns the non-temperature compensated one if the temperature one fails' do
        chart_data = instance_double(ChartData)
        allow(ChartData).to receive(:new).and_return(chart_data)
        allow(chart_data).to receive(:has_chart_data?).and_return(false, true)
        chart_type = GenerateGasDashboardChartConfiguration.new(school, nil, fuel_configuration).generate
        expect(chart_type).to eq Schools::Configuration::TEACHERS_GAS_SIMPLE
      end
    end

    context 'no gas dashboard chart configuration' do
      let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_only, has_electricity: true, has_gas: false) }
      it 'has a nil dashboard set' do
        chart_type = GenerateGasDashboardChartConfiguration.new(school, nil, fuel_configuration).generate
        expect(chart_type).to eq Schools::Configuration::NO_GAS_CHART
      end
    end
  end
end

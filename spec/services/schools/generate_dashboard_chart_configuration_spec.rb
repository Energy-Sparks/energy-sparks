require 'rails_helper'

describe Schools::GenerateDashboardChartConfiguration, type: :service do
  let!(:school)            { create(:school, :with_school_group) }
  let(:meter_collection)   { double(:meter_collection) }
  let(:chart_data)         { instance_double(ChartData) }
  let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true, has_solar_pv: true) }

  let(:service)            { Schools::GenerateDashboardChartConfiguration.new(school, meter_collection, fuel_configuration) }

  it 'generates all expected charts' do
    allow(ChartData).to receive(:new).and_return(chart_data)
    allow(chart_data).to receive(:has_chart_data?).and_return(true)
    charts = service.generate
    expect(charts).to match_array(%i[management_dashboard_group_by_week_electricity management_dashboard_group_by_week_gas management_dashboard_group_by_week_storage_heater management_dashboard_group_by_month_solar_pv])
  end

  context 'school has limited fuel types' do
    let(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: false, has_gas: true, has_storage_heaters: false, has_solar_pv: true) }

    it 'only generates necessary charts' do
      allow(ChartData).to receive(:new).and_return(chart_data)
      allow(chart_data).to receive(:has_chart_data?).and_return(true)
      charts = service.generate
      expect(charts).to match_array(%i[management_dashboard_group_by_week_gas management_dashboard_group_by_month_solar_pv])
    end
  end

  it 'only generates charts that run' do
    allow(ChartData).to receive(:new).and_return(chart_data)
    allow(chart_data).to receive(:has_chart_data?).and_return(false)
    charts = service.generate
    expect(charts).to match_array([])
  end
end

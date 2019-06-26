require 'rails_helper'

module Schools
  describe GenerateChartConfiguration do

    let!(:school)     { create(:school, :with_school_group) }
    let(:page_config) {{
                        main_dashboard_electric:  {
                                name:   'Overview',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_electricity
                                  group_by_week_electricity
                                ]
                              },
                        electricity_detail:      {
                                name:   'Electricity Detail',
                                charts: %i[
                                  daytype_breakdown_electricity
                                  group_by_week_electricity
                                ]
                              },
                        main_dashboard_gas:  {
                                name:   'Main Dashboard',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_gas
                                  group_by_week_gas
                                ]
                              }
                      }}
    let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_only, no_meters_with_validated_readings: false) }
    let(:dashboard_config) {{ electric_only: %i[main_dashboard_electric electricity_detail], gas_only: %i[main_dashboard_gas gas_detail boiler_control] }}

    it 'returns chart config' do
      allow_any_instance_of(ChartData).to receive(:success?).and_return(true)
      GenerateChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate
      page_config.delete(:main_dashboard_gas)

      expect(school.configuration.analysis_charts_as_symbols).to eq page_config
    end
  end
end



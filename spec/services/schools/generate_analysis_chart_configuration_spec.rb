require 'rails_helper'

module Schools

  describe GenerateAnalysisChartConfiguration do

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
                                  baseload
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
                              },
                        main_dashboard_electric_and_gas: {
                                name:   'Overview',
                                charts: %i[
                                  benchmark
                                  daytype_breakdown_electricity
                                  daytype_breakdown_gas
                                  group_by_week_electricity
                                  group_by_week_gas
                                ]
                              },
                        gas_detail:               {
                                name:   'Gas Detail',
                                charts: %i[
                                  daytype_breakdown_gas
                                  group_by_week_gas
                                ]
                              },
                        pupil_analysis: {
                                name:   'Pupil analysis',
                                sub_pages: [
                                  {
                                    name: 'Electric',
                                    charts: %i[
                                      daytype_breakdown_electricity
                                    ]
                                  },
                                  {
                                    name: 'Gas',
                                    charts: %i[
                                      group_by_week_gas
                                    ]
                                  }
                                ]
                              }
                      }}

    let(:dashboard_config) {{
      electric_only: %i[main_dashboard_electric electricity_detail],
      gas_only: %i[main_dashboard_gas gas_detail boiler_control],
      electric_and_gas: %i[main_dashboard_electric_and_gas electricity_detail gas_detail]
    }}

    let(:electric_only_page_config) do
      page_config.delete(:main_dashboard_gas)
      page_config.delete(:main_dashboard_electric_and_gas)
      page_config.delete(:gas_detail)
      page_config.delete(:pupil_analysis)
      page_config
    end

    let(:electric_only_page_config_no_baseload) do
      eopc = electric_only_page_config.clone
      eopc[:electricity_detail][:charts].delete(:baseload)
      eopc
    end

    let(:dual_fuel_failed_electricity) do
      page_config.delete(:main_dashboard_electric)
      page_config.delete(:main_dashboard_gas)
      page_config.delete(:electricity_detail)
      page_config.delete(:pupil_analysis)
      page_config[:main_dashboard_electric_and_gas][:charts].delete(:daytype_breakdown_electricity)
      page_config[:main_dashboard_electric_and_gas][:charts].delete(:group_by_week_electricity)
      page_config
    end

    let(:pupil_analysis_failed_gas) do
      {
        pupil_analysis: {
          name:   'Pupil analysis',
          sub_pages: [
            {
              name: 'Electric',
              charts: %i[
                daytype_breakdown_electricity
              ]
            }
          ]
        }
      }
    end

    let(:chart_data) { instance_double(ChartData) }

    before(:each) do
      allow(ChartData).to receive(:new).and_return(chart_data)
    end

    context 'electric only set up' do
      let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_only, has_electricity: true) }

      it 'returns chart config' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate
        expect(chart_config).to eq electric_only_page_config
      end

      it 'returns chart reduced config if a chart fails' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true, true, true, false, true, true)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate
        expect(chart_config).to eq electric_only_page_config_no_baseload
      end
    end

    context 'dual fuel set up' do
      let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_and_gas, has_electricity: true, has_gas: true) }

      it 'returns a single fuel main dashboard if dual fuel fails' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true, false, true, false, true, false, false, true, true)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate
        expect(chart_config).to eq dual_fuel_failed_electricity
      end
    end

    context 'a configuration with sub pages' do
      let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_and_gas, has_electricity: true, has_gas: true) }

      it 'filters out failing sub pages' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true, false)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate([:pupil_analysis])
        expect(chart_config).to eq pupil_analysis_failed_gas
      end

      it 'filters out a page completely if all sub pages fail' do
        allow(chart_data).to receive(:has_chart_data?).and_return(false, false)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, dashboard_config, page_config).generate([:pupil_analysis])
        expect(chart_config).to eq({})
      end
    end
  end
end

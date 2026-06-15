require 'rails_helper'

module Schools
  describe GenerateAnalysisChartConfiguration do
    let!(:school)     { create(:school, :with_school_group) }
    let(:page_config) do
      {
                        pupil_analysis_page: {
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
                      }
    end

    let(:pupil_analysis_failed_gas) do
      {
        pupil_analysis_page: {
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

    let(:fuel_configuration) { FuelConfiguration.new(fuel_types_for_analysis: :electric_and_gas, has_electricity: true, has_gas: true) }

    let(:chart_data) { instance_double(ChartData) }

    before do
      allow(ChartData).to receive(:new).and_return(chart_data)
    end

    describe '#generate' do
      it 'generates pupil charts' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true, true)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, page_config).generate([:pupil_analysis_page])
        expect(chart_config).to eq page_config
      end

      it 'filters out failing sub pages' do
        allow(chart_data).to receive(:has_chart_data?).and_return(true, false)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, page_config).generate([:pupil_analysis_page])
        expect(chart_config).to eq pupil_analysis_failed_gas
      end

      it 'filters out a page completely if all sub pages fail' do
        allow(chart_data).to receive(:has_chart_data?).and_return(false, false)
        chart_config = GenerateAnalysisChartConfiguration.new(school, nil, fuel_configuration, page_config).generate([:pupil_analysis_page])
        expect(chart_config).to eq({})
      end
    end
  end
end

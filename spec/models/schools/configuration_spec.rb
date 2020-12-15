require 'rails_helper'

module Schools
  describe Configuration do

    let(:school)      { create :school }
    let(:page_config) {{
      main_dashboard_electric:  {
        name:   'One Two',
        charts: [:benchmark]
      },
      pupil_analysis_page:  {
        name:   'One Two',
        sub_pages: [
          {
            name: 'Electricity',
            sub_pages: [
              {
                name: 'Solar',
                charts: [:electric_solar]
              },
              {
                name: 'Storage',
                charts: [:electric_storage]
              }
            ]
          },
          {
            name: 'Gas',
            charts: [:gas_dash]
          }
        ]
      }
    }}

    describe '#dashboard_charts_symbols' do
      it 'returns the dashboard charts in symbol form properly as they get converted to JSON on save' do
        configuration = Configuration.create(school: school, analysis_charts: page_config)

        expect(configuration.analysis_charts).to_not eq page_config
        expect(configuration.analysis_charts_as_symbols).to eq page_config
      end
    end

    describe 'displayable charts' do
      it 'returns suitable electricity chart symbols in order' do
        expect(Configuration.displayable_electricity_dashboard_chart_types).to eq([:teachers_landing_page_electricity])
      end
      it 'returns suitable gas chart symbols in order' do
        expect(Configuration.displayable_gas_dashboard_chart_types).to eq([:teachers_landing_page_gas, :teachers_landing_page_gas_simple])
      end
      it 'returns suitable storage heater chart symbols in order' do
        expect(Configuration.displayable_storage_heater_dashboard_chart_types).to eq([:teachers_landing_page_storage_heaters, :teachers_landing_page_storage_heaters_simple])
      end
    end

    describe '#can_show_analysis_chart?' do
      it 'returns true if the chart is configured' do
        configuration = Configuration.create(school: school, analysis_charts: page_config)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :main_dashboard_electric, :benchmark)).to eq(true)
        expect(configuration.can_show_analysis_chart?(:analysis_charts, :main_dashboard_electric, :other)).to eq(false)
        expect(configuration.can_show_analysis_chart?(:analysis_charts, :main_dashboard_gas, :benchmark)).to eq(false)
      end

      it 'handles nested sub_pages' do
        configuration = Configuration.create(school: school, analysis_charts: page_config)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Nonsense", :blah)).to eq(false)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Gas", :gas_dash)).to eq(true)
        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Gas", :blah)).to eq(false)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Electricity", "Solar", :electric_solar)).to eq(true)
        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Electricity", "Solar", :electric_storage)).to eq(false)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Electricity", "Storage", :electric_storage)).to eq(true)

        expect(configuration.can_show_analysis_chart?(:analysis_charts, :pupil_analysis_page, "Electricity", "Lemons", :electric_storage)).to eq(false)

      end
    end
  end
end

require 'rails_helper'

module Schools
  describe Configuration do

    let(:school)      { create :school }
    let(:page_config) {{
                        main_dashboard_electric:  {
                                name:   'One Two',
                                charts: [:benchmark]
                              },
                      }}

    describe '#dashboard_charts_symbols' do
      it 'returns the dashboard charts in symbol form properly as they get converted to JSON on save' do
        configuration = Configuration.create(school: school, analysis_charts: page_config)

        expect(configuration.analysis_charts).to_not eq page_config
        expect(configuration.analysis_charts_as_symbols).to eq page_config
      end
    end

    describe '#can_show_analysis_chart?' do
      it 'returns true if the chart is configured' do
        configuration = Configuration.create(school: school, analysis_charts: page_config)

        expect(configuration.can_show_analysis_chart?(:main_dashboard_electric, :benchmark)).to eq(true)
        expect(configuration.can_show_analysis_chart?(:main_dashboard_electric, :other)).to eq(false)
        expect(configuration.can_show_analysis_chart?(:main_dashboard_gas, :benchmark)).to eq(false)
      end
    end
  end
end

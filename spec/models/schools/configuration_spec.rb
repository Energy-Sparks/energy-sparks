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
  end
end

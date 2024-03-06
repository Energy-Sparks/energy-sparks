require 'rails_helper'

describe 'weekday_baseload_variation' do
  let!(:school) { create(:school) }
  let(:key) { :weekday_baseload_variation }
  let(:advice_page_key) { :baseload }
  let!(:report) { create(:report, key: key) }

  before do
    create(:advice_page, key: advice_page_key)
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertIntraweekBaseloadVariation'),
                   variables: {
                     percent_intraday_variation: 1,
                     min_day_kw: 2,
                     max_day_kw: 3,
                     min_day_str: 4,
                     max_day_str: 5,
                     annual_cost_gbpcurrent: 6
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    before { visit "/comparisons/#{key}" }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      headers = ['School', 'W/floor area', 'Average peak kw', 'Exemplar peak kw',
                 'Saving if match exemplar (£ at latest tariff)']
      let(:expected_table) do
        [headers,
         ["#{school.name} (*5)", '100&percnt;', '2', '3', '4.0', '5.0', '£6'],
         ["Notes\n(*5) The tariff has changed during the last year for this school. Savings are calculated using the " \
          'latest tariff but other £ values are calculated using the relevant tariff at the time']]
      end
      let(:expected_csv) do
        [headers, [school.name, '100', '2', '3', '4.0', '5.0', '&pound;6']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:chart) { '#chart_comparison' }
    end
  end
end

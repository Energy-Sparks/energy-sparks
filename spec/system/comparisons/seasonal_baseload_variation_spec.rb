# frozen_string_literal: true

require 'rails_helper'

describe 'seasonal_baseload_variation' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertSeasonalBaseloadVariation'),
                   variables: {
                     percent_seasonal_variation: 1,
                     summer_kw: 2,
                     winter_kw: 3,
                     annual_cost_gbpcurrent: 4
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end
  let!(:report) { create(:report, key: key) }
  let(:key) { :seasonal_baseload_variation }
  let(:advice_page_key) { :baseload }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      headers = ['School', 'Percent increase on winter baseload over summer', 'Summer baseload kW',
                 'Winter baseload kW', 'Saving if same all year around (at latest tariff)']
      let(:expected_table) do
        [headers,
         ["#{school.name} [5]", '+100&percnt;', '2', '3', '£4'],
         ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the " \
          'latest tariff but other £ values are calculated using the relevant tariff at the time']]
      end
      let(:expected_csv) do
        [headers, [school.name, '100', '2', '3', '4']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

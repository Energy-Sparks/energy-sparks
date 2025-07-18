# frozen_string_literal: true

require 'rails_helper'

describe 'recent_change_in_baseload' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end
  let(:key) { :recent_change_in_baseload }
  let(:advice_page_key) { :baseload }

  let(:variables) do
    {
      predicted_percent_increase_in_usage: -0.14416360211708243,
      average_baseload_last_year_kw: 2.939355172413793,
      average_baseload_last_week_kw: 2.5156071428571427,
      change_in_baseload_kw: -0.42374802955665025,
      next_year_change_in_baseload_gbpcurrent: -556.8049108374385
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertChangeInElectricityBaseloadShortTerm') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

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
      let(:headers) do
        [
          'School',
          'Change in baseload last week v. year (%)',
          'Average baseload last year (kW)',
          'Average baseload last week (kW)',
          'Change in baseload last week v. year (kW)',
          'Next year cost of change in baseload'
        ]
      end

      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:expected_table) do
        [headers,
         ["#{school.name} [5]", '-14.4&percnt;', '2.94', '2.52', '-0.424', '-£557'],
         ["Notes\n" \
          '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end
      let(:expected_csv) do
        [headers, [school.name, '-14.4', '2.94', '2.52', '-0.424', '-557']]
      end
    end
    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

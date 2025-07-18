# frozen_string_literal: true

require 'rails_helper'

describe 'solar_pv_benefit_estimate' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
    additional_data_alert = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: additional_data_alert,
                   variables: additional_data_variables)
  end
  let(:key) { :solar_pv_benefit_estimate }
  let(:advice_page_key) { :solar_pv }

  let(:variables) do
    {
      optimum_kwp: 44.2,
      optimum_payback_years: 2.5,
      optimum_mains_reduction_percent: 0.15,
      one_year_saving_gbpcurrent: 1000
    }
  end

  let(:additional_data_variables) do
    {
      electricity_economic_tariff_changed_this_year: true
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertSolarPVBenefitEstimator') }
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
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.size_kwp'),
          I18n.t('analytics.benchmarking.configuration.column_headings.payback_years'),
          I18n.t('analytics.benchmarking.configuration.column_headings.reduction_in_mains_consumption_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.saving_optimal_panels')
        ]
      end
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      let(:expected_table) do
        [
          headers,
          ["#{school.name} [5]",
           '44.2',
           '2 years 6 months',
           '15&percnt;',
           '£1,000'],
          ["Notes\n" \
           '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
           'tariff but other £ values are calculated using the relevant tariff at the time' \
           "\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end
      let(:expected_csv) do
        [
          headers,
          [school.name,
           '44.2',
           '2.5',
           '15',
           '1,000']
        ]
      end
    end
  end
end

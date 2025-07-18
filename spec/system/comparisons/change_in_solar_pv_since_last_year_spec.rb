# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_solar_pv_since_last_year' do
  let!(:school) { create(:school) }
  let(:key) { :change_in_solar_pv_since_last_year }
  let(:advice_page_key) { :solar_pv }

  let(:variables) do
    {
      previous_year_solar_pv_kwh: 1000.0,
      current_year_solar_pv_kwh: 1100.0,
      previous_year_solar_pv_co2: 800.0,
      current_year_solar_pv_co2: 900.0,
      solar_type: 'synthetic'
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
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
      let(:headers) do
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.estimated')
        ]
      end
      let(:expected_table) do
        [
          ['', 'kWh', 'CO2 (kg)', 'Solar self consumption'],
          headers,
          [school.name,
           '1,000',
           '1,100',
           '+10&percnt;',
           '800',
           '900',
           '+13&percnt;',
           'Yes'],
          ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end
      let(:expected_csv) do
        [
          ['', 'kWh', '', '', 'CO2 (kg)', '', '', 'Solar self consumption'],
          headers,
          [school.name,
           '1,000',
           '1,100',
           '10',
           '800',
           '900',
           '12.5',
           'Yes']
        ]
      end
    end
  end
end

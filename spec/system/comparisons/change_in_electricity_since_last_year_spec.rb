# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_electricity_since_last_year' do
  let(:variables) do
    {
      previous_year_electricity_kwh: 1000.0,
      current_year_electricity_kwh: 500.0,
      previous_year_electricity_co2: 800.0,
      current_year_electricity_co2: 400.0,
      previous_year_electricity_gbp: 2000.0,
      current_year_electricity_gbp: 1200.0,
      solar_type: 'synthetic'
    }
  end

  let!(:school) { create(:school) }
  let!(:report) { create(:report, key: :change_in_electricity_since_last_year) }

  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)
    alert = create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert, variables: variables)
  end

  before do
    create(:advice_page, key: :electricity_long_term)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_electricity_long_term_path(expected_school) }
      let(:headers) do
        ['School', 'Previous year', 'Last year', 'Change %', 'Previous year', 'Last year', 'Change %', 'Previous year',
         'Last year', 'Change %', 'Estimated']
      end
      let(:expected_table) do
        [
          ['', 'kWh', 'CO2 (kg)', '£', 'Solar self consumption'],
          headers,
          [school.name, '1,000', '500', '-50&percnt;', '800', '400', '-50&percnt;', '£2,000', '£1,200', '-40&percnt;',
           'Yes'],
          ["Notes\nIn school comparisons 'last year' is defined as this year to date."]
        ]
      end
      let(:expected_csv) do
        [
          ['', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', '', 'Solar self consumption'],
          headers,
          [school.name, '1,000', '500', '-50', '800', '400', '-50', '2,000', '1,200', '-40', 'Yes']
        ]
      end
    end
  end
end

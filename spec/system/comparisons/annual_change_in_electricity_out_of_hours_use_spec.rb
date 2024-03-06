# frozen_string_literal: true

require 'rails_helper'

describe 'annual_change_in_electricity_out_of_hours_use' do
  let(:school) { create(:school) }
  let!(:report) { create(:report, key: :annual_change_in_electricity_out_of_hours_use) }

  before do
    create(:advice_page, key: :electricity_out_of_hours)
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOutOfHoursElectricityUsagePreviousYear'),
                   variables: {
                     out_of_hours_kwh: 1,
                     out_of_hours_co2: 3,
                     out_of_hours_gbpcurrent: 5
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertOutOfHoursElectricityUsage'),
                   variables: {
                     out_of_hours_kwh: 2,
                     out_of_hours_co2: 4,
                     out_of_hours_gbpcurrent: 6
                   })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  context 'when viewing report' do
    before { visit comparisons_annual_change_in_electricity_out_of_hours_use_index_path }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { insights_school_advice_electricity_out_of_hours_path(expected_school) }
      let(:headers) do
        ['School',
         'Previous year out of hours kwh',
         'Last year out of hours kwh',
         'Change %',
         'Previous year out of hours co2',
         'Last year out of hours co2',
         'Change %',
         'Previous year out of hours cost at current tariff',
         'Last year out of hours cost at current tariff',
         'Change %']
      end
      let(:expected_table) do
        [['', 'kWh', 'CO2 (kg)', 'Cost'],
         headers,
         ["#{school.name} (*5)", '1', '2', '+100%', '3', '4', '+33%', '£5', '£6', '+20%'],
         ["Notes\n" \
          '(*5) The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end
      let(:expected_csv) do
        [
          ['', 'kWh', '', '', 'CO2 (kg)', '', '', 'Cost', '', ''],
          headers,
          [school.name, '1', '2', '100', '3', '4', '33.3', '5', '6', '20']]
      end
    end
  end
end

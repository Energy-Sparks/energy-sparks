# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_heating_since_last_year' do
  let!(:expected_school) { create(:school) }
  let!(:expected_report) { create(:report, key: key) }
  let(:headers) do
    ['School',
     'Previous year', 'Previous year (temperature adjusted)', 'Last year',
     'Previous year', 'Last year', 'Previous year', 'Last year',
     'Unadjusted change (kWh)', 'Temperature adjusted change (kWh)']
  end
  let(:expected_table) do
    [['', 'kWh', 'CO2 (kg)', '£', 'Percent changed'],
     headers,
     [expected_school.name, '1', '7', '2', '3', '4', '£5', '£6', '+100&percnt;', '+800&percnt;'],
     ["Notes\nIn school comparisons 'last year' is defined as this year to date, 'previous year' is defined as the " \
      'year before.']]
  end
  let(:expected_csv) do
    [['', 'kWh', '', '', 'CO2 (kg)', '', '£', '', 'Percent changed', ''],
     headers,
     [expected_school.name, '1', '7', '2', '3', '4', '5', '6', '100', '8']]
  end

  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: expected_school)
    create(:alert, school: expected_school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: variables)
    create(:alert, school: expected_school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: alert_class_name),
                   variables: { temperature_adjusted_previous_year_kwh: 7,
                                temperature_adjusted_percent: 8 })
  end

  describe 'change_in_gas_since_last_year' do
    let(:alert_class_name) { 'AlertGasAnnualVersusBenchmark' }
    let(:key) { :change_in_gas_since_last_year }
    let(:variables) do
      { previous_year_gas_kwh: 1,
        current_year_gas_kwh: 2,
        previous_year_gas_co2: 3,
        current_year_gas_co2: 4,
        previous_year_gas_gbp: 5,
        current_year_gas_gbp: 6 }
    end

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
  end

  describe 'change_in_storage_heaters_since_last_year' do
    let(:alert_class_name) { 'AlertStorageHeaterAnnualVersusBenchmark' }
    let(:key) { :change_in_storage_heaters_since_last_year }
    let(:variables) do
      { previous_year_storage_heaters_kwh: 1,
        current_year_storage_heaters_kwh: 2,
        previous_year_storage_heaters_co2: 3,
        current_year_storage_heaters_co2: 4,
        previous_year_storage_heaters_gbp: 5,
        current_year_storage_heaters_gbp: 6 }
    end

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
  end
end

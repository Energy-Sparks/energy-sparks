# frozen_string_literal: true

require 'rails_helper'

describe 'annual_change_in_*_out_of_hours_use' do
  let(:expected_school) { create(:school) }
  let(:expected_table) do
    [['', 'kWh', 'CO2 (kg)', 'Cost'],
     headers,
     ["#{expected_school.name} [5]", '1', '2', '+100&percnt;', '3', '4', '+33&percnt;', '£5', '£6', '+20&percnt;'],
     ["Notes\n" \
      '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
      "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
      "'last year' is defined as this year to date."]]
  end
  let(:expected_csv) do
    [['', 'kWh', '', '', 'CO2 (kg)', '', '', 'Cost', '', ''],
     headers,
     [expected_school.name, '1', '2', '100', '3', '4', '33.3', '5', '6', '20']]
  end
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: expected_school)
    create(:alert, school: expected_school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: alert_class_name_previous_year),
                   variables: {
                     out_of_hours_kwh: 1,
                     out_of_hours_co2: 3,
                     out_of_hours_gbpcurrent: 5
                   })
    create(:alert, school: expected_school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: alert_class_name),
                   variables: {
                     out_of_hours_kwh: 2,
                     out_of_hours_co2: 4,
                     out_of_hours_gbpcurrent: 6
                   })
    variables = if alert_class_name == 'AlertOutOfHoursGasUsage'
                  { gas_economic_tariff_changed_this_year: true }
                else
                  { electricity_economic_tariff_changed_this_year: true }
                end
    create(:alert, school: expected_school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: variables)
  end
  let!(:expected_report) { create(:report, key: key) }
  let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
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

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  describe 'annual_change_in_electricity_out_of_hours_use' do
    let(:key) { :annual_change_in_electricity_out_of_hours_use }
    let(:advice_page_key) { :electricity_out_of_hours }
    let(:alert_class_name) { 'AlertOutOfHoursElectricityUsage' }
    let(:alert_class_name_previous_year) { 'AlertOutOfHoursElectricityUsagePreviousYear' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
  end

  describe 'annual_change_in_gas_out_of_hours_use' do
    let(:key) { :annual_change_in_gas_out_of_hours_use }
    let(:advice_page_key) { :gas_out_of_hours }
    let(:alert_class_name) { 'AlertOutOfHoursGasUsage' }
    let(:alert_class_name_previous_year) { 'AlertOutOfHoursGasUsagePreviousYear' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
  end

  describe 'annual_change_in_storage_heater_out_of_hours_use' do
    let(:key) { :annual_change_in_storage_heater_out_of_hours_use }
    let(:advice_page_key) { :storage_heaters }
    let(:alert_class_name) { 'AlertStorageHeaterOutOfHours' }
    let(:alert_class_name_previous_year) { 'AlertOutOfHoursStorageHeaterUsagePreviousYear' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
  end
end

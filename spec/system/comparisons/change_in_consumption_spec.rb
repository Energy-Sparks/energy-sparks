# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_*_consumption_*' do
  let(:schools) { create_list(:school, 3) }
  let!(:alerts) do
    alert_type = create(:alert_type, class_name: alert_class_name)
    common = { current_period_end_date: '2023-04-14',
               current_period_start_date: '2023-04-01',
               current_period_type: 'easter',
               truncated_current_period: false,
               previous_period_end_date: '2022-04-14',
               previous_period_start_date: '2022-04-01',
               previous_period_type: 'easter',
               pupils_changed: false,
               tariff_has_changed: false }
    create(:alert, :with_run, school: schools[0],
                              alert_type: alert_type,
                              variables: common.merge({ difference_percent: 1,
                                                        difference_gbpcurrent: 2,
                                                        difference_kwh: 3,
                                                        truncated_current_period: true,
                                                        pupils_changed: true,
                                                        tariff_has_changed: true }))
    create(:alert, :with_run, school: schools[1],
                              alert_type: alert_type,
                              variables: common.merge({ difference_percent: 'Infinity',
                                                        difference_gbpcurrent: 4,
                                                        difference_kwh: 5 }))
    create(:alert, :with_run, school: schools[2],
                              alert_type: alert_type,
                              variables: common.merge({ difference_percent: '-Infinity',
                                                        difference_gbpcurrent: 6,
                                                        difference_kwh: 7 }))
  end
  let(:expected_school) { schools[0] }
  let(:headers) do
    ['School', 'Change %', 'Change £ (latest tariff)', 'Change kWh', 'Most recent holiday', 'Previous holiday']
  end

  let(:expected_table) do
    [headers,
     ["#{schools[1].name} [2]", '+Infinity&percnt;', '£4', '5', 'Easter 2023', 'Easter 2022'],
     ["#{schools[0].name} [1] [6]", '+100&percnt;', '£2', '3', 'Easter 2023 (partial)', 'Easter 2022'],
     ["#{schools[2].name} [3]", '-Infinity&percnt;', '£6', '7', 'Easter 2023', 'Easter 2022'],
     ["Notes\n" \
      "[1] the comparison has been adjusted because the number of pupils have changed between the two holidays.\n" \
      '[2] schools where percentage change is +Infinity is caused by the electricity consumption in the ' \
      "previous holidays being more than zero but in the current holidays zero\n" \
      '[3] schools where percentage change is -Infinity is caused by the electricity consumption in the current ' \
      "holidays being zero but in the previous holidays it was more than zero\n" \
      '[6] schools where the economic tariff has changed between the two periods, this is not reflected in the ' \
      "'Change £ (latest tariff)' column as it is calculated using the most recent tariff."]]
  end
  let(:expected_csv) do
    [headers,
     [schools[1].name, 'Infinity', '4', '5', 'Easter 2023', 'Easter 2022'],
     [schools[0].name, '100', '2', '3', 'Easter 2023 (partial)', 'Easter 2022'],
     [schools[2].name, '-Infinity', '6', '7', 'Easter 2023', 'Easter 2022']]
  end
  let!(:expected_report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) do
      [electricity_change_rows, electricity_infinite_increase, electricity_infinite_decrease, tariff_changed_in_period]
    end
  end

  describe 'change_in_electricity_holiday_consumption_previous_years_holiday' do
    let(:alert_class_name) { 'AlertPreviousYearHolidayComparisonElectricity' }
    let(:key) { :change_in_electricity_holiday_consumption_previous_years_holiday }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'change_in_electricity_holiday_consumption_previous_holiday' do
    let(:alert_class_name) { 'AlertPreviousHolidayComparisonElectricity' }
    let(:key) { :change_in_electricity_holiday_consumption_previous_holiday }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'change_in_gas_holiday_consumption_previous_holiday' do
    let(:alert_class_name) { 'AlertPreviousHolidayComparisonGas' }
    let(:key) { :change_in_gas_holiday_consumption_previous_holiday }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'change_in_gas_holiday_consumption_previous_years_holiday' do
    let(:alert_class_name) { 'AlertPreviousYearHolidayComparisonGas' }
    let(:key) { :change_in_gas_holiday_consumption_previous_years_holiday }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end
end

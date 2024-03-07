# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_electricity_holiday_consumption_previous_years_holiday' do
  let(:schools) { create_list(:school, 3) }
  let!(:report) { create(:report, key: :change_in_electricity_holiday_consumption_previous_years_holiday) }

  before do
    alert_type = create(:alert_type, class_name: 'AlertPreviousYearHolidayComparisonElectricity')
    create(:alert, :with_run, school: schools[0],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: 1,
                                difference_gbpcurrent: 2,
                                difference_kwh: 3,
                                current_period_type: 'easter',
                                truncated_current_period: true,
                                previous_period_type: 'easter',
                                pupils_changed: true,
                                tariff_has_changed: true
                              })
    create(:alert, :with_run, school: schools[1],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: 'Infinity',
                                difference_gbpcurrent: 4,
                                difference_kwh: 5,
                                current_period_type: 'easter',
                                truncated_current_period: false,
                                previous_period_type: 'easter',
                                pupils_changed: false,
                                tariff_has_changed: false
                              })
    create(:alert, :with_run, school: schools[2],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: '-Infinity',
                                difference_gbpcurrent: 6,
                                difference_kwh: 7,
                                current_period_type: 'easter',
                                truncated_current_period: false,
                                previous_period_type: 'easter',
                                pupils_changed: false,
                                tariff_has_changed: false
                              })
  end

  context 'when viewing report' do
    before { visit comparisons_change_in_electricity_holiday_consumption_previous_years_holiday_index_path }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      headers = ['School', 'Change %', 'Change £ (latest tariff)', 'Change kWh', 'Most recent holiday',
                 'Previous holiday']
      let(:expected_table) do
        [headers,
         ["#{schools[1].name} (*2)", '+Infinity%', '£4', '5', 'Easter', 'Easter'],
         ["#{schools[0].name} (*1) (*6)", '+100%', '£2', '3', 'Easter (partial)', 'Easter'],
         ["#{schools[2].name} (*3)", '-Infinity%', '£6', '7', 'Easter', 'Easter'],
         ["Notes\n" \
          '(*1) the comparison has been adjusted because the number of pupils have changed between the two holidays. ' \
          '(*2) schools where percentage change is +Infinity is caused by the electricity consumption in the ' \
          'previous holidays being more than zero but in the current holidays zero ' \
          '(*3) schools where percentage change is -Infinity is caused by the electricity consumption in the current ' \
          'holidays being zero but in the previous holidays it was more than zero ' \
          '(*6) schools where the economic tariff has changed between the two periods, this is not reflected in the ' \
          "'Change £ (latest tariff)' column as it is calculated using the most recent tariff."]]
      end
      let(:expected_csv) do
        [headers,
         [schools[1].name, 'Infinity', '4', '5', 'Easter', 'Easter'],
         [schools[0].name, '100', '2', '3', 'Easter (partial)', 'Easter'],
         [schools[2].name, '-Infinity', '6', '7', 'Easter', 'Easter']]
      end
    end

    it_behaves_like 'a school comparison report with a chart'
  end
end

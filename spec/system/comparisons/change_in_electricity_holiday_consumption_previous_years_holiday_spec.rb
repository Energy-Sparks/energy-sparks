# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:schools) { create_list(:school, 3) }

  before do
    create(:alert, school: schools[0],
                   alert_generation_run: create(:alert_generation_run, school: schools[0]),
                   alert_type: create(:alert_type, class_name: 'AlertPreviousYearHolidayComparisonElectricity'),
                   variables: {
                     difference_percent: 1,
                     difference_gbpcurrent: 2,
                     difference_kwh: 3,
                     name_of_current_period: 'current',
                     truncated_current_period: true,
                     name_of_previous_period: 'previous',
                     pupils_changed: true,
                     tariff_has_changed: true
                   })
    create(:alert, school: schools[1],
                   alert_generation_run: create(:alert_generation_run, school: schools[1]),
                   alert_type: create(:alert_type, class_name: 'AlertPreviousYearHolidayComparisonElectricity'),
                   variables: {
                     difference_percent: 'Infinity',
                     difference_gbpcurrent: 4,
                     difference_kwh: 5,
                     name_of_current_period: 'current',
                     truncated_current_period: false,
                     name_of_previous_period: 'previous',
                     pupils_changed: false,
                     tariff_has_changed: false
                   })
    create(:alert, school: schools[2],
                   alert_generation_run: create(:alert_generation_run, school: schools[2]),
                   alert_type: create(:alert_type, class_name: 'AlertPreviousYearHolidayComparisonElectricity'),
                   variables: {
                     difference_percent: '-Infinity',
                     difference_gbpcurrent: 6,
                     difference_kwh: 7,
                     name_of_current_period: 'current',
                     truncated_current_period: false,
                     name_of_previous_period: 'previous',
                     pupils_changed: false,
                     tariff_has_changed: false
                   })
  end

  context 'when viewing report' do
    before { visit comparisons_change_in_electricity_holiday_consumption_previous_years_holiday_index_path }

    it_behaves_like 'a school comparison report', advice_page: false do
      let(:title) do
        I18n.t('analytics.benchmarking.chart_table_config' \
               '.change_in_electricity_holiday_consumption_previous_years_holiday')
      end
      let(:expected_school) { schools[0] }
    end

    it 'displays the expected data' do
      expect(page).to have_css('#comparison-table tr', count: 5)
      expect(all('#comparison-table tr').map { |tr| tr.all('th,td').map(&:text) }).to eq(
        [['School', 'Change %', 'Change £ (latest tariff)', 'Change kWh', 'Most recent holiday', 'Previous holiday'],
         ["#{schools[1].name} (*2)", '+Infinity%', '£4', '5', 'current', 'previous'],
         ["#{schools[0].name} (*1) (*6)", '+100%', '£2', '3', 'current (partial)', 'previous'],
         ["#{schools[2].name} (*3)", '-Infinity%', '£6', '7', 'current', 'previous'],
         ["Notes\n" \
          '(*1) the comparison has been adjusted because the number of pupils have changed between the two holidays. ' \
          '(*2) schools where percentage change is +Infinity is caused by the electricity consumption in the ' \
          'previous holidays being more than zero but in the current holidays zero ' \
          '(*3) schools where percentage change is -Infinity is caused by the electricity consumption in the current ' \
          'holidays being zero but in the previous holidays it was more than zero ' \
          '(*6) schools where the economic tariff has changed between the two periods, this is not reflected in the ' \
          "'Change £ (latest tariff)' column as it is calculated using the most recent tariff."]]
      )
    end
  end
end

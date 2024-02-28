# frozen_string_literal: true

require 'rails_helper'

describe 'electricity_peak_kw_per_pupil' do
  let(:school) { create(:school) }

  before do
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
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
  end

  context 'when viewing report' do
    before { visit comparisons_change_in_electricity_holiday_consumption_previous_years_holiday_index_path }

    it_behaves_like 'a school comparison report', advice_page: false do
      let(:title) { I18n.t('analytics.benchmarking.chart_table_config.change_in_electricity_holiday_consumption_previous_years_holiday') }
      let(:expected_school) { school }
    end

    it 'displays the expected data' do
      expect(page).to have_css('#comparison-table tr', count: 3)
      expect(all('#comparison-table tr').map { |tr| tr.all('th,td').map(&:text) }).to eq(
        [['School', 'Change %', 'Change £ (latest tariff)', 'Change kWh', 'Most recent holiday', 'Previous holiday'],
         ["#{school.name} (*1) (*6)", '+100%', '£2', '3', 'current (partial)', 'previous'],
         ["Notes\n" \
          '(*1) the comparison has been adjusted because the number of pupils have changed between the two holidays. ' \
          '(*6) schools where the economic tariff has changed between the two periods, this is not reflected in the ' \
          "'Change £ (latest tariff)' column as it is calculated using the most recent tariff."]]
      )
    end
  end
end

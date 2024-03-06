# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_electricity_consumption_recent_school_weeks' do
  let(:schools) { create_list(:school, 3) }
  let!(:report) { create(:report, key: :change_in_electricity_consumption_recent_school_weeks)}

  before do
    alert_type = create(:alert_type, class_name: 'AlertSchoolWeekComparisonElectricity')
    create(:alert, :with_run, school: schools[0],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: 1,
                                difference_gbpcurrent: 2,
                                difference_kwh: 3,
                                pupils_changed: true,
                                tariff_has_changed: true
                              })
    create(:alert, :with_run, school: schools[1],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: 'Infinity',
                                difference_gbpcurrent: 4,
                                difference_kwh: 5,
                                pupils_changed: false,
                                tariff_has_changed: false
                              })
    create(:alert, :with_run, school: schools[2],
                              alert_type: alert_type,
                              variables: {
                                difference_percent: '-Infinity',
                                difference_gbpcurrent: 6,
                                difference_kwh: 7,
                                pupils_changed: false,
                                tariff_has_changed: false
                              })
  end

  context 'when viewing report' do
    before { visit comparisons_change_in_electricity_consumption_recent_school_weeks_path }

    it_behaves_like 'a school comparison report', advice_page: false do
      let(:title) { report.title }
      let(:expected_school) { schools[0] }
      let(:expected_table) do
        [['School', 'Change %', 'Change £ (latest tariff)', 'Change kWh'],
         ["#{schools[1].name} (*2)", '+Infinity%', '£4', '5'],
         ["#{schools[0].name} (*1) (*6)", '+100%', '£2', '3'],
         ["#{schools[2].name} (*3)", '-Infinity%', '£6', '7'],
         ["Notes\n" \
          '(*1) the comparison has been adjusted because the number of pupils have changed between the two holidays. ' \
          '(*2) schools where percentage change is +Infinity is caused by the electricity consumption in the ' \
          'previous holidays being more than zero but in the current holidays zero ' \
          '(*3) schools where percentage change is -Infinity is caused by the electricity consumption in the current ' \
          'holidays being zero but in the previous holidays it was more than zero ' \
          '(*6) schools where the economic tariff has changed between the two periods, this is not reflected in the ' \
          "'Change £ (latest tariff)' column as it is calculated using the most recent tariff."]]
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe '*_consumption_during_holiday' do
  let(:expected_school) { create(:school) }
  let!(:expected_report) { create(:report, key:) }
  let(:headers) { ['School', 'Projected usage by end of holiday', 'Holiday usage to date', 'Holiday'] }
  let(:expected_table) do
    [headers, [expected_school.name, '£1', '£2', 'Easter 2023']]
  end
  let(:expected_csv) do
    [headers, [expected_school.name, '1', '2', 'Easter 2023']]
  end
  let!(:alerts) do
    alert_generation_run = create(:alert_generation_run, school: expected_school)
    alert_classes.map.with_index do |alert_class, i|
      create(:alert, school: expected_school,
                     alert_generation_run:,
                     alert_type: create(:alert_type, class_name: alert_class.name),
                     enough_data: i == 0 ? 1 : 0,
                     variables: { holiday_projected_usage_gbp: 1,
                                  holiday_usage_to_date_gbp: 2,
                                  holiday_type: 'easter',
                                  holiday_start_date: '2023-04-01',
                                  holiday_end_date: '2023-04-14' })
    end
  end

  before { travel_to Date.new(2023, 4, 1) }

  {
    electricity_consumption_during_holiday: [AlertElectricityUsageDuringCurrentHoliday,
                                             Alerts::Electricity::UsageDuringCurrentHolidayWithCommunityUse],
    gas_consumption_during_holiday: [AlertGasHeatingHotWaterOnDuringHoliday,
                                     Alerts::Gas::HeatingHotWaterOnDuringHolidayWithCommunityUse],
    storage_heater_consumption_during_holiday: [AlertStorageHeaterHeatingOnDuringHoliday,
                                                Alerts::StorageHeater::HeatingOnDuringHolidayWithCommunityUse]
  }.flat_map { |key, classes| classes.permutation.map { |classes| [classes] + [key] } }
    .each do |alert_classes, key|
      describe "#{key} - #{alert_classes.first}" do
        let(:alert_classes) { alert_classes }
        let(:key) { key }

        it_behaves_like 'a school comparison report'
        it_behaves_like 'a school comparison report with a table'
        it_behaves_like 'a school comparison report with a chart'
      end
  end
end

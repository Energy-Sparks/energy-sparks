# frozen_string_literal: true

require 'rails_helper'

describe '*_consumption_during_holiday' do
  let(:expected_school) { create(:school) }
  let!(:expected_report) { create(:report, key: key) }
  let(:headers) { ['School', 'Projected usage by end of holiday', 'Holiday usage to date', 'Holiday'] }
  let(:expected_table) do
    [headers, [expected_school.name, '£1', '£2', 'Easter 2023']]
  end
  let(:expected_csv) do
    [headers, [expected_school.name, '1', '2', 'Easter 2023']]
  end
  let!(:alerts) do
    create(:alert, :with_run, school: expected_school,
                              alert_type: create(:alert_type, class_name: alert_class),
                              variables: {
                                holiday_projected_usage_gbp: 1,
                                holiday_usage_to_date_gbp: 2,
                                holiday_type: 'easter',
                                holiday_start_date: '2023-04-01',
                                holiday_end_date: '2023-04-14'
                              })
  end

  before do
    travel_to Date.new(2023, 4, 1)
  end

  describe 'electricity_consumption_during_holiday' do
    let(:alert_class) { 'AlertElectricityUsageDuringCurrentHoliday' }
    let(:key) { 'electricity_consumption_during_holiday' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'gas_consumption_during_holiday' do
    let(:alert_class) { 'AlertGasHeatingHotWaterOnDuringHoliday' }
    let(:key) { 'gas_consumption_during_holiday' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end

  describe 'storage_heater_consumption_during_holiday' do
    let(:alert_class) { 'AlertStorageHeaterHeatingOnDuringHoliday' }
    let(:key) { 'storage_heater_consumption_during_holiday' }

    it_behaves_like 'a school comparison report'
    it_behaves_like 'a school comparison report with a table'
    it_behaves_like 'a school comparison report with a chart'
  end
end

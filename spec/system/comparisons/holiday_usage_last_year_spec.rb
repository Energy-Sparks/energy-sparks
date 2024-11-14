# frozen_string_literal: true

require 'rails_helper'

describe 'holiday_usage_last_year' do
  let!(:school) { create(:school) }
  let(:key) { :holiday_usage_last_year }

  let(:variables) do
    {
      last_year_holiday_gas_gbp: 1414.9566810000001,
      last_year_holiday_electricity_gbp: 4778.43,
      last_year_holiday_gas_gbpcurrent: 1414.9566810000001,
      last_year_holiday_electricity_gbpcurrent: 4778.43,
      last_year_holiday_gas_kwh_per_floor_area: 2.9478264187500005,
      last_year_holiday_electricity_kwh_per_floor_area: 28.960181818181812,
      last_year_holiday_type: 'easter',
      last_year_holiday_start_date: '2023-04-01',
      last_year_holiday_end_date: '2023-04-14',
      holiday_start_date: '2024-04-01'
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertImpendingHoliday') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
  end

  context 'when viewing report' do
    before do
      travel_to Date.new(2024, 3, 30)
    end

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { school_advice_path(expected_school) }

      let(:headers) do
        ['School',
         'Gas cost (historic tariff)',
         'Electricity cost (historic tariff)',
         'Gas cost (current tariff)',
         'Electricity cost (current tariff)',
         'Gas kWh per floor area per holiday',
         'Electricity kWh per pupil per holiday',
         'Holiday']
      end

      let(:expected_table) do
        [headers,
         [school.name, '£1,410', '£4,780', '£1,410', '£4,780', '2.95', '29', 'Easter 2023']]
      end

      let(:expected_csv) do
        [headers,
         [school.name, '1,410', '4,780', '1,410', '4,780', '2.95', '29', 'Easter 2023']]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

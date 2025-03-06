# frozen_string_literal: true

require 'rails_helper'

describe 'solar_generation_summary' do
  let!(:school) { create(:school) }
  let(:key) { :solar_generation_summary }
  let(:advice_page_key) { :solar_pv }

  let(:variables) do
    {
      annual_solar_pv_kwh: 2500,
      annual_solar_pv_consumed_onsite_kwh: 2000,
      annual_exported_solar_pv_kwh: 500,
      annual_mains_consumed_kwh: 1000,
      annual_electricity_kwh: 4000
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertSolarGeneration') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:headers) do
        ['School', 'Generation (kWh)', 'Self consumption (kWh)', 'Export (kWh)', 'Mains consumption (kWh)',
         'Total onsite consumption (kWh)']
      end
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      let(:expected_table) do
        [
          headers,
          [school.name,
           '2,500',
           '2,000',
           '500',
           '1,000',
           '4,000']
        ]
      end
      let(:expected_csv) do
        [
          headers,
          [school.name,
           '2,500',
           '2,000',
           '500',
           '1,000',
           '4,000']
        ]
      end
    end
  end
end

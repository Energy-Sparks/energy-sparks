# frozen_string_literal: true

require 'rails_helper'

describe 'heating_vs_hot_water' do
  let!(:school) { create(:school) }
  let(:key) { :heating_vs_hot_water }
  let(:advice_page_key) { :hot_water }
  let!(:report) { create(:report, key: key) }
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: AlertGasAnnualVersusBenchmark.name),
                   variables: { last_year_kwh: 10 })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: AlertHotWaterEfficiency.name),
                   variables: { existing_gas_annual_kwh: 5 })
  end

  before do
    create(:advice_page, key: advice_page_key)
  end

  context 'when viewing report' do
    before { visit "/comparisons/#{key}" }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }

      let(:headers) do
        ['School', 'Gas', 'Hot Water Gas', 'Heating Gas', 'Percentage of gas use for hot water']
      end

      let(:expected_table) do
        [['', 'kWh', ''], headers, [school.name, '10', '5', '5', '50&percnt;']]
      end

      let(:expected_csv) do
        [['', 'kWh', '', '', ''], headers, [school.name, '10', '5', '5', '0.5']]
      end
    end
  end
end

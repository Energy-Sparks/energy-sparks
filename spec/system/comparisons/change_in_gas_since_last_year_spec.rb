require 'rails_helper'

describe 'change_in_gas_since_last_year' do
  let!(:school) { create(:school) }
  let(:key) { :change_in_gas_since_last_year }
  let!(:report) { create(:report, key: key) }

  before do
    alert_run = create(:alert_generation_run, school: school)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: { previous_year_gas_kwh: 1,
                                current_year_gas_kwh: 2,
                                previous_year_gas_co2: 3,
                                current_year_gas_co2: 4,
                                previous_year_gas_gbp: 5,
                                current_year_gas_gbp: 6 })
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark'),
                   variables: { temperature_adjusted_previous_year_kwh: 7,
                                temperature_adjusted_percent: 8 })
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
      headers = ['School',
                 'Previous year', 'Previous year (temperature adjusted)', 'Last year',
                 'Previous year', 'Last year', 'Previous year', 'Last year',
                 'Unadjusted change (kWh)', 'Temperature adjusted change (kWh)']
      let(:expected_table) do
        [['', 'kWh', 'CO2 (kg)', '£', 'Percent changed'],
         headers,
         [school.name, '1', '7', '2', '3', '4', '£5', '£6', '+100%', '+800%']]
      end
      let(:expected_csv) do
        [['', 'kWh', '', '', 'CO2 (kg)', '', '£', '', 'Percent changed', ''],
         headers,
         [school.name, '1', '7', '2', '3', '4', '5', '6', '100', '8']]
      end
    end
  end
end

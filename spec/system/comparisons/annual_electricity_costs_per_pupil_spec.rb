# frozen_string_literal: true

require 'rails_helper'

describe 'annual_electricity_costs_per_pupil' do
  let!(:school) { create(:school) }
  let(:key) { :annual_electricity_costs_per_pupil }
  let(:advice_page_key) { :electricity_long_term }

  let(:variables) do
    {
      one_year_electricity_per_pupil_gbp: 274.74452694610767,
      one_year_electricity_per_pupil_kwh: 874.1419161676646,
      one_year_electricity_per_pupil_co2: 119.51184730538925,
      last_year_gbp: 45882.33599999998,
      last_year_kwh: 145981.69999999998,
      last_year_co2: 19958.478500000005,
      one_year_saving_versus_exemplar_gbpcurrent: 7724.021623024759
    }
  end

  let(:alert_type) { create(:alert_type, class_name: 'AlertElectricityAnnualVersusBenchmark') }
  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { electricity_economic_tariff_changed_this_year: true })
  end

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
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
      let(:colgroups) do
        ['', 'Last year', 'Last year per pupil', '']
      end
      let(:headers) do
        ['School',
         'kWh',
         '£',
         'kg/CO2',
         'kWh',
         '£',
         'kg/CO2',
         'Potential savings']
      end

      let(:expected_table) do
        [colgroups,
         headers,
         ["#{school.name} [5]",
          '146,000',
          '£45,882',
          '20,000',
          '874',
          '£275',
          '120',
          '£7,720'],
         ["Notes\n" \
          '[5] The tariff has changed during the last year for this school. Savings are calculated using the latest ' \
          "tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons " \
          "'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [['', 'Last year', '', '', 'Last year per pupil', '', '', ''],
         headers,
         [school.name,
          '146,000',
          '45,900',
          '20,000',
          '874',
          '275',
          '120',
          '7,720']]
      end
    end
  end
end

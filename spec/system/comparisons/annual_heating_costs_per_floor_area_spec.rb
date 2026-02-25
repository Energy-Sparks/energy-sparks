# frozen_string_literal: true

require 'rails_helper'

describe 'annual_heating_costs_per_floor_area' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertStorageHeaterAnnualVersusBenchmark'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: {
                     gas_economic_tariff_changed_this_year: true,
                     electricity_economic_tariff_changed_this_year: true
                   })
  end
  let(:key) { :annual_heating_costs_per_floor_area }
  let(:advice_page_key) { :gas_long_term }

  let(:gas_variables) do
    {
      one_year_gas_per_floor_area_co2: 21.239315786816878,
      one_year_gas_per_floor_area_gbp: 6.514057089992596,
      one_year_gas_per_floor_area_kwh: 116.32244803558191,
      last_year_co2:  28651.83699641597,
      last_year_gbp: 8787.463014400011,
      last_year_kwh: 156918.9824,
      one_year_saving_versus_exemplar_gbpcurrent: 5662.080886786545
    }
  end

  let(:storage_heater_variables) do
    {
      last_year_co2: 775.2947948734521,
      last_year_gbp: 1543.5154008486109,
      last_year_kwh: 5849.096774220592,
      one_year_gas_per_floor_area_co2: 0.7369722384728632,
      one_year_gas_per_floor_area_gbp: 1.4672199627838507,
      one_year_gas_per_floor_area_kwh: 5.55997792226292,
      one_year_saving_versus_exemplar_gbpcurrent: -8657.807686721897
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
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
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      let(:table_name) { :gas }

      let(:colgroups) do
        ['', 'Last year', 'Last year per m²', '']
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
          '157,000',
          '£8,787',
          '28,700',
          '116',
          '£7',
          '21.2',
          '£5,660'],
         ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [['', 'Last year', '', '', 'Last year per m²', '', '', ''],
         headers,
         [school.name, '157,000', '8,790', '28,700', '116', '6.51', '21.2', '5,660']]
      end
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
      let(:table_name) { :storage_heater }

      let(:colgroups) do
        ['', 'Last year', 'Last year per m²', '']
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
          '5,850',
          '£1,544',
          '775',
          '5.56',
          '£1',
          '0.737',
          ''],
         ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time\nIn school comparisons 'last year' is defined as this year to date."]]
      end

      let(:expected_csv) do
        [['', 'Last year', '', '', 'Last year per m²', '', '', ''],
         headers,
         [school.name, '5,850', '1,540', '775', '5.56', '1.47', '0.737', '']]
      end
    end


    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

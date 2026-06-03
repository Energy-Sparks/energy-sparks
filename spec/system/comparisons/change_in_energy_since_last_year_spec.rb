# frozen_string_literal: true

require 'rails_helper'

describe 'change_in_energy_since_last_year' do
  let!(:school) { create(:school, :with_fuel_configuration) }
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)

    alert_type = create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark')
    create(:alert, school: school, alert_generation_run: alert_run, alert_type: alert_type, variables: variables)

    alert_type = create(:alert_type, class_name: 'AlertAdditionalPrioritisationData')
    create(
      :alert,
      school: school,
      alert_generation_run: alert_run,
      alert_type: alert_type,
      variables: {
        electricity_economic_tariff_changed_this_year: true,
        gas_economic_tariff_changed_this_year: true
      }
    )
  end
  let(:key) { :change_in_energy_since_last_year }

  let(:variables) do
    {
      current_year_electricity_kwh: 1000.0,
      previous_year_electricity_kwh: 2000.0,
      current_year_electricity_co2: 100.0,
      previous_year_electricity_co2: 200.0,
      current_year_electricity_gbp: 2000.0,
      previous_year_electricity_gbp: 4000.0,

      current_year_gas_kwh: 1000.0,
      previous_year_gas_kwh: 2000.0,
      current_year_gas_co2: 100.0,
      previous_year_gas_co2: 200.0,
      current_year_gas_gbp: 2000.0,
      previous_year_gas_gbp: 4000.0,

      current_year_storage_heaters_kwh: 1000.0,
      previous_year_storage_heaters_kwh: 2000.0,
      current_year_storage_heaters_co2: 100.0,
      previous_year_storage_heaters_co2: 200.0,
      current_year_storage_heaters_gbp: 2000.0,
      previous_year_storage_heaters_gbp: 4000.0,

      current_year_solar_pv_kwh: 1000.0,
      previous_year_solar_pv_kwh: 2000.0,
      current_year_solar_pv_co2: 100.0,
      previous_year_solar_pv_co2: 200.0,

      solar_type: 'synthetic'
    }
  end

  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [tariff_changed_last_year] }
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with a table' do
      let(:expected_report) { report }
      let(:expected_school) { school }
      let(:advice_page_path) { school_advice_path(expected_school) }

      let(:colgroups) do
        [
          '',
          I18n.t('analytics.benchmarking.configuration.column_groups.metering'),
          I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
          I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
          I18n.t('analytics.benchmarking.configuration.column_groups.cost')
        ]
      end

      let(:headers) do
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('analytics.benchmarking.configuration.column_headings.fuel'),
          I18n.t('comparisons.column_headings.recent_data'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
          I18n.t('analytics.benchmarking.configuration.column_headings.previous_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.last_year'),
          I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
        ]
      end

      let(:expected_table) do
        [
          colgroups,
          headers,
          ["#{school.name} [#{tariff_changed_last_year[:label]}]",
           '',
           'Yes',
           '8,000',
           '4,000',
           '-50&percnt;',
           '800',
           '400',
           '-50&percnt;',
           '£12,000',
           '£6,000',
           '-50&percnt;'],
          ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
        ]
      end

      let(:expected_csv) do
        [
          ['', 'Metering', '', 'kWh', '', '', 'CO2 (kg)', '', '', 'Cost', '', ''],
          headers,
          [
            school.name,
            'Electricity;Gas;Storage heaters;Solar PV',
            'Yes',
            '8,000',
            '4,000',
            '-50',
            '800',
            '400',
            '-50',
            '12,000',
            '6,000',
            '-50'
          ]
        ]
      end
    end
  end
end

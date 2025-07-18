require 'rails_helper'

describe 'annual_energy_use' do
  let!(:school) { create(:school) }
  let(:key) { :annual_energy_use }

  let(:electricity_variables) do
    {
      last_year_kwh: 1000.0,
      last_year_co2: 100.0,
      last_year_gbp: 1500.0
    }
  end

  let(:gas_variables) do
    {
      last_year_kwh: 2000.0,
      last_year_co2: 200.0,
      last_year_gbp: 2500.0
    }
  end

  let(:storage_heater_variables) do
    {
      last_year_kwh: 3000.0,
      last_year_co2: 300.0,
      last_year_gbp: 3500.0
    }
  end

  let(:additional_variables) do
    {
      school_type_name: 'Primary',
      pupils: 100,
      floor_area: 5000.0,
      electricity_economic_tariff_changed_this_year: true,
      gas_economic_tariff_changed_this_year: true
    }
  end

  let(:alert_run) { create(:alert_generation_run, school: school) }
  let!(:report) { create(:report, key: key) }

  let!(:alerts) do
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertElectricityAnnualVersusBenchmark'),
                   variables: electricity_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertGasAnnualVersusBenchmark'),
                   variables: gas_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertStorageHeaterAnnualVersusBenchmark'),
                   variables: storage_heater_variables)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: additional_variables)
  end

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
          I18n.t('analytics.benchmarking.configuration.column_groups.electricity_consumption'),
          I18n.t('analytics.benchmarking.configuration.column_groups.gas_consumption'),
          I18n.t('analytics.benchmarking.configuration.column_groups.storage_heater_consumption'),
          ''
        ]
      end

      let(:headers) do
        [
          I18n.t('analytics.benchmarking.configuration.column_headings.school'),
          I18n.t('comparisons.column_headings.recent_data'),
          I18n.t('kwh'),
          I18n.t('£'),
          I18n.t('co2'),
          I18n.t('kwh'),
          I18n.t('£'),
          I18n.t('co2'),
          I18n.t('kwh'),
          I18n.t('£'),
          I18n.t('co2'),
          I18n.t('analytics.benchmarking.configuration.column_headings.type'),
          I18n.t('analytics.benchmarking.configuration.column_headings.pupils'),
          I18n.t('analytics.benchmarking.configuration.column_headings.floor_area')
        ]
      end

      let(:expected_table) do
        [
          colgroups,
          headers,
          [
            "#{school.name} [#{tariff_changed_last_year[:label]}]",
            'Yes',
            '1,000',
            '£1,500',
            '100',
            '2,000',
            '£2,500',
            '200',
            '3,000',
            '£3,500',
            '300',
            'Primary',
            '100',
            '5,000'
          ],
          ["Notes\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
        ]
      end

      let(:expected_csv) do
        [
          ['', '', 'Electricity consumption', '', '', 'Gas consumption', '', '', 'Storage heater consumption', '', '',
           '', '', ''],
          headers,
          [
            school.name,
            'Yes',
            '1,000',
            '1,500',
            '100',
            '2,000',
            '2,500',
            '200',
            '3,000',
            '3,500',
            '300',
            'Primary',
            '100',
            '5,000'
          ]
        ]
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

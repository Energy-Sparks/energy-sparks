require 'rails_helper'

describe 'change_in_energy_use_since_joined_energy_sparks' do
  let!(:school) { create(:school) }
  let(:key) { :change_in_energy_use_since_joined_energy_sparks }

  let(:variables) do
    {
      current_year_electricity_kwh: 1000.0,
      activationyear_electricity_kwh: 2000.0,
      current_year_electricity_co2: 100.0,
      activationyear_electricity_co2: 200.0,
      current_year_electricity_gbp: 2000.0,
      activationyear_electricity_gbp: 4000.0,

      current_year_gas_kwh: 1000.0,
      activationyear_gas_kwh: 2000.0,
      current_year_gas_co2: 100.0,
      activationyear_gas_co2: 200.0,
      current_year_gas_gbp: 2000.0,
      activationyear_gas_gbp: 4000.0,

      current_year_storage_heaters_kwh: 1000.0,
      activationyear_storage_heaters_kwh: 2000.0,
      current_year_storage_heaters_co2: 100.0,
      activationyear_storage_heaters_co2: 200.0,
      current_year_storage_heaters_gbp: 2000.0,
      activationyear_storage_heaters_gbp: 4000.0,

      activationyear_electricity_kwh_relative_percent: 0.1,
      activationyear_gas_kwh_relative_percent: 0.1,
      activationyear_storage_heaters_kwh_relative_percent: 0.1,

      solar_type: 'synthetic'
    }
  end

  let!(:report) { create(:report, key: key) }

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
      variables: { activation_date: Date.new(2023, 1, 1) }
    )
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    it_behaves_like 'a school comparison report with multiple tables',
                    table_titles: [
                      I18n.t('comparisons.tables.total_usage'),
                      I18n.t('comparisons.tables.electricity_usage'),
                      I18n.t('comparisons.tables.gas_usage'),
                      I18n.t('comparisons.tables.storage_heater_usage')
                    ] do
      let(:expected_report) { report }
    end

    context 'with a total table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { school_advice_path(expected_school) }
        let(:table_name) { :total }

        let(:colgroups) do
          [
            '',
            I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
            I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            I18n.t('analytics.benchmarking.configuration.column_groups.gbp')
          ]
        end
        let(:headers) do
          [
            I18n.t('analytics.benchmarking.configuration.column_headings.school'),
            I18n.t('analytics.benchmarking.configuration.column_headings.fuel'),
            I18n.t('activerecord.attributes.school.activation_date'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
          ]
        end

        let(:expected_table) do
          [
            colgroups,
            headers,
            [school.name,
             '',
             'Jan 2023',
             '6,000',
             '3,000',
             '-50&percnt;',
             '600',
             '300',
             '-50&percnt;',
             '£12,000',
             '£6,000',
             '-50&percnt;']
          ]
        end

        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [
              school.name,
              'Electricity;Gas;Storage heaters',
              '2023-01-01',
              '6,000',
              '3,000',
              '-50',
              '600',
              '300',
              '-50',
              '12,000',
              '6,000',
              '-50'
            ]
          ]
        end
      end
    end

    context 'with an electricity table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { school_advice_path(school) }
        let(:table_name) { :electricity }

        let(:colgroups) do
          [
            '',
            I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
            I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            I18n.t('analytics.benchmarking.configuration.column_groups.gbp')
          ]
        end
        let(:headers) do
          [
            I18n.t('analytics.benchmarking.configuration.column_headings.school'),
            I18n.t('activerecord.attributes.school.activation_date'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
          ]
        end

        let(:expected_table) do
          [
            colgroups,
            headers,
            [school.name,
             'Jan 2023',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;']
          ]
        end

        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             '2,000',
             '1,000',
             '-50',
             '200',
             '100',
             '-50',
             '4,000',
             '2,000',
             '-50']
          ]
        end
      end
    end

    context 'with a gas table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { school_advice_path(school) }
        let(:table_name) { :gas }

        let(:colgroups) do
          [
            '',
            I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
            I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            I18n.t('analytics.benchmarking.configuration.column_groups.gbp')
          ]
        end
        let(:headers) do
          [
            I18n.t('analytics.benchmarking.configuration.column_headings.school'),
            I18n.t('activerecord.attributes.school.activation_date'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
          ]
        end

        let(:expected_table) do
          [
            colgroups,
            headers,
            [school.name,
             'Jan 2023',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;']
          ]
        end

        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             '2,000',
             '1,000',
             '-50',
             '200',
             '100',
             '-50',
             '4,000',
             '2,000',
             '-50']
          ]
        end
      end
    end

    context 'with a storage heater table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { school_advice_path(school) }
        let(:table_name) { :storage_heater }

        let(:colgroups) do
          [
            '',
            I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
            I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            I18n.t('analytics.benchmarking.configuration.column_groups.gbp')
          ]
        end
        let(:headers) do
          [
            I18n.t('analytics.benchmarking.configuration.column_headings.school'),
            I18n.t('activerecord.attributes.school.activation_date'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
            I18n.t('comparisons.column_headings.previous_period'),
            I18n.t('comparisons.column_headings.current_period'),
            I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
          ]
        end

        let(:expected_table) do
          [
            colgroups,
            headers,
            [school.name,
             'Jan 2023',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;']
          ]
        end

        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             '2,000',
             '1,000',
             '-50',
             '200',
             '100',
             '-50',
             '4,000',
             '2,000',
             '-50']
          ]
        end
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { report }
    end
  end
end

require 'rails_helper'

describe 'heat_saver_march_2024' do
  let!(:school) { create(:school) }
  let(:key) { :heat_saver_march_2024 }
  let(:advice_page_key) { :total_energy_use }

  # change to your variables
  let(:usage_variables) do
    {
      current_period_kwh: 1000.0,
      previous_period_kwh: 2000.0,
      current_period_co2: 100.0,
      previous_period_co2: 200.0,
      current_period_gbp: 2000.0,
      previous_period_gbp: 4000.0,
      tariff_has_changed: true,
      pupils_changed: true,
      floor_area_changed: true
    }
  end

  let(:heating_usage_variables) do
    {
      current_period_kwh: 1000.0,
      previous_period_kwh: 2000.0,
      previous_period_kwh_unadjusted: 1800.0,
      current_period_co2: 100.0,
      previous_period_co2: 200.0,
      current_period_gbp: 2000.0,
      previous_period_gbp: 4000.0,
      tariff_has_changed: true,
      pupils_changed: true,
      floor_area_changed: true
    }
  end

  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [electricity_change_rows, gas_change_rows, tariff_changed_last_year] }
  end

  before do
    create(:advice_page, key: advice_page_key)
    alert_run = create(:alert_generation_run, school: school)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { activation_date: Date.new(2023, 1, 1) })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: { solar_type: 'metered' })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024ElectricityComparison'),
                   variables: usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024GasComparison'),
                   variables: heating_usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHeatSaver2024StorageHeaterComparison'),
                   variables: heating_usage_variables)
  end

  context 'when viewing report' do
    before { visit "/comparisons/#{key}" }

    it_behaves_like 'a school comparison report' do
      let(:expected_report) { report }
    end

    context 'with a total table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
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
            ["#{school.name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}] [#{gas_change_rows[:label]}]",
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
             '-50&percnt;'
            ],
            ["Notes\n[1] the comparison has been adjusted because the floor area has changed between the two periods for some schools. [1] the comparison has been adjusted because the number of pupils have changed between the two periods. [5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [
              school.name,
              '',
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
        let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
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
            ["#{school.name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'
            ],
            ["Notes\n[1] the comparison has been adjusted because the number of pupils have changed between the two periods. [5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
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
             '-50'
            ]
          ]
        end
      end
    end

    context 'with a gas table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
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
            I18n.t('comparisons.column_headings.previous_period_unadjusted'),
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
            ["#{school.name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '1,800',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'
            ],
            ["Notes\n[1] the comparison has been adjusted because the floor area has changed between the two periods for some schools. [5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             '1,800',
             '2,000',
             '1,000',
             '-50',
             '200',
             '100',
             '-50',
             '4,000',
             '2,000',
             '-50'
            ]
          ]
        end
      end
    end

    context 'with a storage heater table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { report }
        let(:expected_school) { school }
        let(:advice_page_path) { polymorphic_path([:insights, expected_school, :advice, advice_page_key]) }
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
            I18n.t('comparisons.column_headings.previous_period_unadjusted'),
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
            ["#{school.name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '1,800',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'
            ],
            ["Notes\n[1] the comparison has been adjusted because the number of pupils have changed between the two periods. [5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             '1,800',
             '2,000',
             '1,000',
             '-50',
             '200',
             '100',
             '-50',
             '4,000',
             '2,000',
             '-50'
            ]
          ]
        end
      end
    end

    it_behaves_like 'a school comparison report with a chart'
  end
end

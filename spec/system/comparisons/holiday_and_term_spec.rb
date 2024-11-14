require 'rails_helper'

describe 'holiday_and_term' do
  let!(:school) { create(:school) }
  let!(:alerts) do
    alert_run = create(:alert_generation_run, school: school)
    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertAdditionalPrioritisationData'),
                   variables: { activation_date: Date.new(2023, 1, 1) })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertEnergyAnnualVersusBenchmark'),
                   variables: { solar_type: 'metered' })

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHolidayAndTermElectricityComparison'),
                   variables: usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHolidayAndTermGasComparison'),
                   variables: heating_usage_variables)

    create(:alert, school: school, alert_generation_run: alert_run,
                   alert_type: create(:alert_type, class_name: 'AlertHolidayAndTermStorageHeaterComparison'),
                   variables: heating_usage_variables)
  end
  let(:key) { :holiday_and_term }

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
      floor_area_changed: true,
      current_period_end_date: '2023-04-14',
      current_period_start_date: '2023-04-01',
      current_period_type: 'easter',
      truncated_current_period: false
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
      floor_area_changed: true,
      current_period_end_date: '2023-04-14',
      current_period_start_date: '2023-04-01',
      current_period_type: 'easter',
      truncated_current_period: false
    }
  end

  let!(:report) { create(:report, key: key) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [electricity_change_rows, gas_change_rows, tariff_changed_last_year] }
  end

  context 'when viewing report' do
    before do
      create(:advice_page, key: :electricity_out_of_hours)
      create(:advice_page, key: :gas_out_of_hours)
    end

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
             '-50&percnt;'],
            ["Notes\n[1] the comparison has been adjusted because the floor area has changed between the two periods for some schools.\n[1] the comparison has been adjusted because the number of pupils have changed between the two periods.\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
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
        let(:advice_page_path) do
          "#{analysis_school_advice_electricity_out_of_hours_path(expected_school)}#holiday-usage"
        end
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
            I18n.t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
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
             'Easter 2023',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'],
            ["Notes\n[1] the comparison has been adjusted because the number of pupils have changed between the two periods.\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             'Easter 2023',
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
        let(:advice_page_path) { "#{analysis_school_advice_gas_out_of_hours_path(expected_school)}#holiday-usage" }
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
            I18n.t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
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
             'Easter 2023',
             '1,800',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'],
            ["Notes\n[1] the comparison has been adjusted because the floor area has changed between the two periods for some schools.\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             'Easter 2023',
             '1,800',
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
        let(:advice_page_path) { school_advice_path(expected_school) }
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
            I18n.t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
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
             'Easter 2023',
             '1,800',
             '2,000',
             '1,000',
             '-50&percnt;',
             '200',
             '100',
             '-50&percnt;',
             '£4,000',
             '£2,000',
             '-50&percnt;'],
            ["Notes\n[1] the comparison has been adjusted because the number of pupils have changed between the two periods.\n[5] The tariff has changed during the last year for this school. Savings are calculated using the latest tariff but other £ values are calculated using the relevant tariff at the time"]
          ]
        end

        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [school.name,
             '2023-01-01',
             'Easter 2023',
             '1,800',
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

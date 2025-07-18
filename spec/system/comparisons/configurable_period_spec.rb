# frozen_string_literal: true

require 'rails_helper'

describe 'configurable_period' do
  let!(:schools) { create_list(:school, 6) }
  let!(:alerts) do
    create(:alert_type, class_name: AlertAdditionalPrioritisationData.name)
    create(:alert_type, class_name: AlertEnergyAnnualVersusBenchmark.name)
    create(:alert_type, class_name: AlertConfigurablePeriodElectricityComparison.name)
    create(:alert_type, class_name: AlertConfigurablePeriodGasComparison.name)
    create(:alert_type, class_name: AlertConfigurablePeriodStorageHeaterComparison.name)

    create_alerts(schools[0], Date.new(2023, 1, 1), electricity: true, gas: true, storage_heater: true)
    create_alerts(schools[1], Date.new(2023, 2, 1))
    create_alerts(schools[2], Date.new(2023, 3, 1), gas: true)
    create_alerts(schools[3], Date.new(2023, 4, 1), electricity: true)
    create_alerts(schools[4], Date.new(2023, 5, 1), electricity: true, gas: true)
    create_alerts(schools[5], Date.new(2023, 6, 1), electricity: true, storage_heater: true)
  end
  let!(:reports) { create_list(:report, 2, :with_custom_period) }

  include_context 'with comparison report footnotes' do
    let(:footnotes) { [electricity_change_rows, gas_change_rows, tariff_changed_last_year] }
  end

  def create_alerts(school, activation_date, electricity: false, gas: false, storage_heater: false)
    alert_run = create(:alert_generation_run, school:)
    create(:alert, school:, alert_generation_run: alert_run,
                   alert_type: AlertType.find_by(class_name: AlertAdditionalPrioritisationData.name),
                   variables: { activation_date: })
    create(:alert, school:, alert_generation_run: alert_run,
                   alert_type: AlertType.find_by(class_name: AlertEnergyAnnualVersusBenchmark.name),
                   variables: { solar_type: 'metered' })
    variables = {
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
    reports.each do |comparison_report|
      if electricity
        create(:alert, school:, alert_generation_run: alert_run,
                       alert_type: AlertType.find_by(class_name: AlertConfigurablePeriodElectricityComparison.name),
                       variables:,
                       comparison_report:)
      end
      heating_usage_variables = variables.merge(previous_period_kwh_unadjusted: 1800.0)
      if gas
        create(:alert, school:, alert_generation_run: alert_run,
                       alert_type: AlertType.find_by(class_name: AlertConfigurablePeriodGasComparison.name),
                       variables: heating_usage_variables,
                       comparison_report:)
      end
      if storage_heater # rubocop:disable Style/Next
        create(:alert, school:, alert_generation_run: alert_run,
                       alert_type: AlertType.find_by(class_name: AlertConfigurablePeriodStorageHeaterComparison.name),
                       variables: heating_usage_variables,
                       comparison_report:)
      end
    end
  end

  self::COL_GROUPS = [ # rubocop:disable RSpec/LeakyConstantDeclaration -- shouldn't leak because of self?
    '',
    I18n.t('analytics.benchmarking.configuration.column_groups.kwh'),
    I18n.t('analytics.benchmarking.configuration.column_groups.co2_kg'),
    I18n.t('analytics.benchmarking.configuration.column_groups.gbp')
  ].freeze

  def generate_headers(fuel:, unadjusted:)
    [
      I18n.t('analytics.benchmarking.configuration.column_headings.school'),
      fuel && I18n.t('analytics.benchmarking.configuration.column_headings.fuel'),
      I18n.t('activerecord.attributes.school.activation_date'),
      unadjusted && I18n.t('comparisons.column_headings.previous_period_unadjusted'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct'),
      I18n.t('comparisons.column_headings.previous_period'),
      I18n.t('comparisons.column_headings.current_period'),
      I18n.t('analytics.benchmarking.configuration.column_headings.change_pct')
    ].select(&:itself)
  end

  context 'when viewing report' do
    it_behaves_like 'a school comparison report' do
      let(:expected_report) { reports[0] }
      let(:model) { Comparison::ConfigurablePeriod }
    end

    it_behaves_like 'a school comparison report with multiple tables',
                    table_titles: [
                      I18n.t('comparisons.tables.total_usage'),
                      I18n.t('comparisons.tables.electricity_usage'),
                      I18n.t('comparisons.tables.gas_usage'),
                      I18n.t('comparisons.tables.storage_heater_usage')
                    ] do
      let(:expected_report) { reports[0] }
      let(:model) { Comparison::ConfigurablePeriod }
    end

    context 'with a total table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { reports[0] }
        let(:model) { Comparison::ConfigurablePeriod }
        let(:expected_school) { schools[0] }
        let(:advice_page_path) { school_advice_path(expected_school) }
        let(:table_name) { :total }
        let(:colgroups) { self.class::COL_GROUPS }
        let(:headers) { generate_headers(fuel: true, unadjusted: false) }
        let(:expected_table) do
          footnotes = \
            "[#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}] [#{gas_change_rows[:label]}]"
          [
            colgroups,
            headers,
            ["#{schools[0].name} #{footnotes}",
             '',
             'Jan 2023',
             '6,000', '3,000', '-50&percnt;',
             '600', '300', '-50&percnt;',
             '£12,000', '£6,000', '-50&percnt;'],
            ["#{schools[2].name} #{footnotes}",
             '',
             'Mar 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[3].name} #{footnotes}",
             '',
             'Apr 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[4].name} #{footnotes}",
             '',
             'May 2023',
             '4,000', '2,000', '-50&percnt;',
             '400', '200', '-50&percnt;',
             '£8,000', '£4,000', '-50&percnt;'],
            ["#{schools[5].name} #{footnotes}",
             '',
             'Jun 2023',
             '4,000', '2,000', '-50&percnt;',
             '400', '200', '-50&percnt;',
             '£8,000', '£4,000', '-50&percnt;'],
            # TODO: two [1]s?
            ["Notes\n" \
             '[1] the comparison has been adjusted because the floor area has changed between the two periods ' \
             "for some schools.\n" \
             '[1] the comparison has been adjusted because the number of pupils have changed between the two ' \
             "periods.\n" \
             '[5] The tariff has changed during the last year for this school. Savings are calculated using the ' \
             'latest tariff but other £ values are calculated using the relevant tariff at the time']
          ]
        end
        let(:expected_csv) do
          [
            ['', '', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [schools[0].name,
             'Electricity;Gas;Storage heaters',
             '2023-01-01',
             '6,000', '3,000', '-50',
             '600', '300', '-50',
             '12,000', '6,000', '-50'],
            [schools[2].name,
             'Gas',
             '2023-03-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[3].name,
             'Electricity',
             '2023-04-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[4].name,
             'Electricity;Gas',
             '2023-05-01',
             '4,000', '2,000', '-50',
             '400', '200', '-50',
             '8,000', '4,000', '-50'],
            [schools[5].name,
             'Electricity;Storage heaters',
             '2023-06-01',
             '4,000', '2,000', '-50',
             '400', '200', '-50',
             '8,000', '4,000', '-50']
          ]
        end
      end
    end

    context 'with an electricity table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { reports[0] }
        let(:model) { Comparison::ConfigurablePeriod }
        let(:expected_school) { schools[0] }
        let(:advice_page_path) { school_advice_path(expected_school) }
        let(:table_name) { :electricity }
        let(:colgroups) { self.class::COL_GROUPS }
        let(:headers) { generate_headers(fuel: false, unadjusted: false) }
        let(:expected_table) do
          [
            colgroups,
            headers,
            ["#{schools[0].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[3].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Apr 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[4].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'May 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[5].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jun 2023',
             '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["Notes\n" \
             '[1] the comparison has been adjusted because the number of pupils have changed between the two ' \
             "periods.\n" \
             '[5] The tariff has changed during the last year for this school. Savings are calculated using the ' \
             'latest tariff but other £ values are calculated using the relevant tariff at the time']
          ]
        end
        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [schools[0].name,
             '2023-01-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[3].name,
             '2023-04-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[4].name,
             '2023-05-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[5].name,
             '2023-06-01',
             '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50']
          ]
        end
      end
    end

    context 'with a gas table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { reports[0] }
        let(:model) { Comparison::ConfigurablePeriod }
        let(:expected_school) { schools[0] }
        let(:advice_page_path) { school_advice_path(expected_school) }
        let(:table_name) { :gas }
        let(:colgroups) { self.class::COL_GROUPS }
        let(:headers) { generate_headers(fuel: false, unadjusted: true) }
        let(:expected_table) do
          [
            colgroups,
            headers,
            ["#{schools[0].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '1,800', '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[2].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Mar 2023',
             '1,800', '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[4].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'May 2023',
             '1,800', '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["Notes\n" \
             '[1] the comparison has been adjusted because the floor area has changed between the two periods for ' \
             "some schools.\n" \
             '[5] The tariff has changed during the last year for this school. Savings are calculated using the ' \
             'latest tariff but other £ values are calculated using the relevant tariff at the time']
          ]
        end
        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [schools[0].name,
             '2023-01-01',
             '1,800', '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[2].name,
             '2023-03-01',
             '1,800', '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[4].name,
             '2023-05-01',
             '1,800', '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50']
          ]
        end
      end
    end

    context 'with a storage heater table' do
      it_behaves_like 'a school comparison report with a table' do
        let(:expected_report) { reports[0] }
        let(:model) { Comparison::ConfigurablePeriod }
        let(:expected_school) { schools[0] }
        let(:advice_page_path) { school_advice_path(expected_school) }
        let(:table_name) { :storage_heater }
        let(:colgroups) { self.class::COL_GROUPS }
        let(:headers) { generate_headers(fuel: false, unadjusted: true) }
        let(:expected_table) do
          [
            colgroups,
            headers,
            ["#{schools[0].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jan 2023',
             '1,800', '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["#{schools[5].name} [#{tariff_changed_last_year[:label]}] [#{electricity_change_rows[:label]}]",
             'Jun 2023',
             '1,800', '2,000', '1,000', '-50&percnt;',
             '200', '100', '-50&percnt;',
             '£4,000', '£2,000', '-50&percnt;'],
            ["Notes\n" \
             '[1] the comparison has been adjusted because the number of pupils have changed between the two ' \
             "periods.\n" \
             '[5] The tariff has changed during the last year for this school. Savings are calculated using the ' \
             'latest tariff but other £ values are calculated using the relevant tariff at the time']
          ]
        end
        let(:expected_csv) do
          [
            ['', '', 'kWh', '', '', '', 'CO2 (kg)', '', '', '£', '', ''],
            headers,
            [schools[0].name,
             '2023-01-01',
             '1,800', '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50'],
            [schools[5].name,
             '2023-06-01',
             '1,800', '2,000', '1,000', '-50',
             '200', '100', '-50',
             '4,000', '2,000', '-50']
          ]
        end
      end
    end

    it_behaves_like 'a school comparison report with a chart' do
      let(:expected_report) { reports[0] }
      let(:model) { Comparison::ConfigurablePeriod }
    end
  end
end

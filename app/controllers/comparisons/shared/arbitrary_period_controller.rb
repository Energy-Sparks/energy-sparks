# frozen_string_literal: true

module Comparisons
  module Shared
    class ArbitraryPeriodController < BaseController
      include MultipleTableComparison

      private

      def set_headers(include_previous_period_unadjusted: true, holiday_name: false)
        super()
        @include_previous_period_unadjusted = include_previous_period_unadjusted
        electricity_groups = header_groups(fuel: false, holiday_name: holiday_name)
        @electricity_colgroups = colgroups(groups: electricity_groups)
        @electricity_headers = headers(groups: electricity_groups)
        heating_groups = header_groups(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted,
                                       holiday_name: holiday_name)
        @heating_colgroups = colgroups(groups: heating_groups)
        @heating_headers = headers(groups: heating_groups)
        @period_type_string = I18n.t('comparisons.period_types.periods')
      end

      def header_groups(fuel: true, previous_period_unadjusted: false, holiday_name: false)
        [
          { label: '',
            headers: [
              t('analytics.benchmarking.configuration.column_headings.school'),
              fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
              t('activerecord.attributes.school.activation_date'),
              holiday_name && t('analytics.benchmarking.configuration.column_headings.most_recent_holiday')
            ] },
          { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
            headers: [
              previous_period_unadjusted && t('comparisons.column_headings.previous_period_unadjusted'),
              t('comparisons.column_headings.previous_period'),
              t('comparisons.column_headings.current_period'),
              t('analytics.benchmarking.configuration.column_headings.change_pct')
            ], },
          { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'),
            headers: [
              t('comparisons.column_headings.previous_period'),
              t('comparisons.column_headings.current_period'),
              t('analytics.benchmarking.configuration.column_headings.change_pct')
            ] },
          { label: t('analytics.benchmarking.configuration.column_groups.gbp'),
            headers: [
              t('comparisons.column_headings.previous_period'),
              t('comparisons.column_headings.current_period'),
              t('analytics.benchmarking.configuration.column_headings.change_pct')
            ] }
        ]
      end

      def table_configuration
        {
          total: I18n.t('comparisons.tables.total_usage'),
          electricity: I18n.t('comparisons.tables.electricity_usage'),
          gas: I18n.t('comparisons.tables.gas_usage'),
          storage_heater: I18n.t('comparisons.tables.storage_heater_usage')
        }
      end

      def create_charts(_results)
        create_single_number_chart(@results, :total_percentage_change_kwh, 100.0, :change_kwh, :percent)
      end
    end
  end
end

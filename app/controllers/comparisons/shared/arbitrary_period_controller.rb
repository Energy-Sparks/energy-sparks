# frozen_string_literal: true

module Comparisons
  module Shared
    class ArbitraryPeriodController < BaseController
      include MultipleTableComparison

      private

      def set_headers(include_previous_period_unadjusted: true)
        super()
        @include_previous_period_unadjusted = include_previous_period_unadjusted
        @electricity_colgroups = colgroups(fuel: false)
        @electricity_headers = headers(fuel: false)
        @heating_colgroups = colgroups(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted)
        @heating_headers = headers(fuel: false, previous_period_unadjusted: @include_previous_period_unadjusted)
        @period_type_string = I18n.t('comparisons.period_types.periods')
      end

      def headers(fuel: true, previous_period_unadjusted: false, holiday_name: false)
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
          t('activerecord.attributes.school.activation_date'),
          holiday_name && t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
          previous_period_unadjusted && t('comparisons.column_headings.previous_period_unadjusted'),
          t('comparisons.column_headings.previous_period'),
          t('comparisons.column_headings.current_period'),
          t('analytics.benchmarking.configuration.column_headings.change_pct'),
          t('comparisons.column_headings.previous_period'),
          t('comparisons.column_headings.current_period'),
          t('analytics.benchmarking.configuration.column_headings.change_pct'),
          t('comparisons.column_headings.previous_period'),
          t('comparisons.column_headings.current_period'),
          t('analytics.benchmarking.configuration.column_headings.change_pct')
        ].select(&:itself)
      end

      def colgroups(fuel: true, previous_period_unadjusted: false, holiday_name: false)
        [
          { label: '', colspan: fuel || holiday_name ? 3 : 2 },
          { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
            colspan: previous_period_unadjusted ? 4 : 3 },
          { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
          { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
        ]
      end

      def advice_page_key
        :total_energy_use
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

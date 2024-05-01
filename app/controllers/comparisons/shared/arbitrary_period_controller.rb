# frozen_string_literal: true

module Comparisons
  module Shared
    class ArbitraryPeriodController < BaseController
      def index
        @electricity_colgroups = colgroups(fuel: false)
        @electricity_headers = headers(fuel: false)
        @heating_colgroups = colgroups(fuel: false, previous_period_unadjusted: true)
        @heating_headers = headers(fuel: false, previous_period_unadjusted: true)
        @period_type_string = I18n.t('comparisons.period_types.periods')
        super
      end

      private

      def headers(fuel: true, previous_period_unadjusted: false)
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          fuel && t('analytics.benchmarking.configuration.column_headings.fuel'),
          t('activerecord.attributes.school.activation_date'),
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

      def colgroups(fuel: true, previous_period_unadjusted: false)
        [
          { label: '', colspan: fuel ? 3 : 2 },
          { label: t('analytics.benchmarking.configuration.column_groups.kwh'),
            colspan: previous_period_unadjusted ? 4 : 3 },
          { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
          { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 3 }
        ]
      end

      def advice_page_key
        :total_energy_use
      end

      def table_names
        %i[total electricity gas storage_heater]
      end

      def create_charts(_results)
        create_single_number_chart(@results, :total_percentage_change_kwh, 100.0, :change_kwh, :percent)
      end
    end
  end
end

# frozen_string_literal: true

module Comparisons
  module Shared
    class ChangeInHeatingSinceLastYearController < BaseController
      private

      def colgroups
        [{ label: '' },
         { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
         { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 2 },
         { label: t('analytics.benchmarking.configuration.column_groups.gbp'), colspan: 2 },
         { label: t('analytics.benchmarking.configuration.column_groups.percent_changed'), colspan: 2 }]
      end

      def headers
        [t('analytics.benchmarking.configuration.column_headings.school'),
         t('analytics.benchmarking.configuration.column_headings.previous_year'),
         t('analytics.benchmarking.configuration.column_headings.previous_year_temperature_adjusted'),
         t('analytics.benchmarking.configuration.column_headings.last_year'),
         t('analytics.benchmarking.configuration.column_headings.previous_year'),
         t('analytics.benchmarking.configuration.column_headings.last_year'),
         t('analytics.benchmarking.configuration.column_headings.previous_year'),
         t('analytics.benchmarking.configuration.column_headings.last_year'),
         t('analytics.benchmarking.configuration.column_headings.unadjusted_kwh'),
         t('analytics.benchmarking.configuration.column_headings.temperature_adjusted_kwh')]
      end

      def key
        :change_in_gas_since_last_year
      end

      def load_data
        model.for_schools(@schools).where.not(temperature_adjusted_percent: nil)
             .order(temperature_adjusted_percent: :asc)
      end
    end
  end
end

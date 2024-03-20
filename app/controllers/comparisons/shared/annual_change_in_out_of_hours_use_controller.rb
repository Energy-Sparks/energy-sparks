# frozen_string_literal: true

module Comparisons
  module Shared
    class AnnualChangeInOutOfHoursUseController < BaseController
      private

      def colgroups
        [{ label: '' },
         { label: t('analytics.benchmarking.configuration.column_groups.kwh'), colspan: 3 },
         { label: t('analytics.benchmarking.configuration.column_groups.co2_kg'), colspan: 3 },
         { label: t('analytics.benchmarking.configuration.column_groups.cost'), colspan: 3 }]
      end

      def headers
        [t('analytics.benchmarking.configuration.column_headings.school'),
         t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_kwh'),
         t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_kwh'),
         t('analytics.benchmarking.configuration.column_headings.change_pct'),
         t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_co2'),
         t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_co2'),
         t('analytics.benchmarking.configuration.column_headings.change_pct'),
         t('analytics.benchmarking.configuration.column_headings.previous_year_out_of_hours_cost_ct'),
         t('analytics.benchmarking.configuration.column_headings.last_year_out_of_hours_cost_ct'),
         t('analytics.benchmarking.configuration.column_headings.change_pct')]
      end

      def load_data
        model.for_schools(@schools).where.not(previous_out_of_hours_kwh: nil).order(previous_out_of_hours_kwh: :desc)
      end
    end
  end
end

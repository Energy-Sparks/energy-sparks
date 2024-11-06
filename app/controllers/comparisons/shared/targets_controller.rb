# frozen_string_literal: true

module Comparisons
  module Shared
    class TargetsController < BaseController
      private

      def headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('schools.school_targets.target_table.target_reduction'),
          t('schools.school_targets.target_table.current_progress'),
          t('analytics.benchmarking.configuration.column_headings.target_kwh_consumption'),
          t('analytics.benchmarking.configuration.column_headings.kwh_consumption_since_target_set'),
          t('analytics.benchmarking.configuration.column_headings.start_date_for_target')
        ]
      end

      def load_data
        model.for_schools(@schools).with_data.sort_default
      end

      def create_charts(results)
        # i18n-tasks-use t('analytics.benchmarking.configuration.column_headings.percent_above_or_below_target_since_target_set')
        create_single_number_chart(results, :current_year_percent_of_target_relative, 100.0, :percent_above_or_below_target_since_target_set, :percent)
      end
    end
  end
end

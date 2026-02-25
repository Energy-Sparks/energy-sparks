# frozen_string_literal: true

module Comparisons
  module Shared
    class ChangeInConsumptionController < BaseController
      private

      def headers
        [t('analytics.benchmarking.configuration.column_headings.school'),
         t('analytics.benchmarking.configuration.column_headings.change_pct'),
         t('analytics.benchmarking.configuration.column_headings.change_£current'),
         t('analytics.benchmarking.configuration.column_headings.change_kwh'),
         t('analytics.benchmarking.configuration.column_headings.most_recent_holiday'),
         t('analytics.benchmarking.configuration.column_headings.previous_holiday')]
      end

      def recent_school_weeks_headers
        [t('analytics.benchmarking.configuration.column_headings.school'),
         t('analytics.benchmarking.configuration.column_headings.change_pct'),
         t('analytics.benchmarking.configuration.column_headings.change_£current'),
         t('analytics.benchmarking.configuration.column_headings.change_kwh')]
      end

      def create_charts(results)
        create_single_number_chart(results, :difference_percent, 100.0, 'change_pct', 'percent', x_max_value: 100.0)
      end

      def load_data
        model.for_schools(@schools).where.not(difference_percent: nil).order(difference_percent: :desc)
      end
    end
  end
end

# frozen_string_literal: true

module Comparisons
  module Shared
    class ConsumptionDuringHolidayController < BaseController
      private

      def headers
        [
          t('analytics.benchmarking.configuration.column_headings.school'),
          t('analytics.benchmarking.configuration.column_headings.projected_usage_by_end_of_holiday'),
          t('analytics.benchmarking.configuration.column_headings.holiday_usage_to_date'),
          t('analytics.benchmarking.configuration.column_headings.holiday')
        ]
      end

      def load_data
        model.for_schools(@schools)
             .where.not(holiday_projected_usage_gbp: nil)
             .where(holiday_start_date: Time.zone.today..)
             .order(holiday_projected_usage_gbp: :desc)
      end

      def create_charts(results)
        create_single_number_chart(results, :holiday_projected_usage_gbp, nil, 'projected_usage_by_end_of_holiday', '£')
      end
    end
  end
end

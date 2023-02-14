module Schools
  module Advice
    class ElectricityIntradayController < AdviceBaseController
      def insights
        @peak_usage_benchmarking = build_peak_usage_benchmarking
        @peak_usage_calculation = build_peak_usage_calculation(asof_date)
        @peak_usage_calculation_1_year_ago = build_peak_usage_calculation(previous_years_asof_date)
        @peak_kw_usage_percentage_change = calculate_percentage_change_in_peak_kw
      end

      def analysis
        @analysis_dates = analysis_dates
      end

      private

      def create_analysable
        OpenStruct.new(
          enough_data?: analysis_dates.one_years_data
        )
      end

      def calculate_percentage_change_in_peak_kw
        old_peak_kw = @peak_usage_calculation_1_year_ago&.average_peak_kw
        new_peak_kw = @peak_usage_calculation&.average_peak_kw

        percent_change(old_peak_kw, new_peak_kw)
      end

      # Copied from ContentBase
      def percent_change(old_value, new_value)
        return nil if old_value.nil? || new_value.nil?
        return 0.0 if !old_value.nan? && old_value == new_value # both 0.0 case

        (new_value - old_value) / old_value
      end

      def build_peak_usage_benchmarking
        ::Usage::PeakUsageBenchmarkingService.new(
          meter_collection: aggregate_school,
          asof_date: asof_date
        )
      end

      def build_peak_usage_calculation(date)
        ::Usage::PeakUsageCalculationService.new(
          meter_collection: aggregate_school,
          asof_date: date
        )
      end

      def asof_date
        @asof_date ||= AggregateSchoolService.analysis_date(aggregate_school, :electricity)
      end

      def previous_years_asof_date
        @previous_years_asof_date ||= asof_date - 1.year
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end

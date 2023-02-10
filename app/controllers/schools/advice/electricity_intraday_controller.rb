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

      def calculate_percentage_change_in_peak_kw
        # Calculates the relative change between last years average peak kw value
        # and this years average peak kw value
        old_peak_kw = @peak_usage_calculation_1_year_ago.average_peak_kw
        new_peak_kw = @peak_usage_calculation.average_peak_kw
        (new_peak_kw - old_peak_kw) / old_peak_kw # * 100
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

      def create_analysable
        OpenStruct.new(
          enough_data?: analysis_dates.one_years_data
        )
      end

      def advice_page_key
        :electricity_intraday
      end
    end
  end
end

module Schools
  module Advice
    class OutOfHoursUsageService
      include AnalysableMixin

      def initialize(school, aggregate_school_service, fuel_type)
        @school = school
        @aggregate_school_service = aggregate_school_service
        @fuel_type = fuel_type
      end

      def enough_data?
        @enough_data ||= annual_usage_breakdown_service.enough_data?
      end

      def data_available_from
        @data_available_from ||= annual_usage_breakdown_service.data_available_from
      end

      def annual_usage_breakdown
        @annual_usage_breakdown ||= annual_usage_breakdown_service.usage_breakdown
      end

      def benchmarked_usage
        @benchmarked_usage ||= Schools::Comparison.new(
          school_value: annual_usage_breakdown.out_of_hours.kwh,
          benchmark_value: (annual_usage_breakdown.total.kwh * benchmark_value(:benchmark_school)),
          exemplar_value: (annual_usage_breakdown.total.kwh * benchmark_value(:exemplar_school)),
          unit: :kwh
        )
      end

      def benchmark_value(comparison)
        Schools::AdvicePageBenchmarks::OutOfHoursUsageBenchmarkGenerator.benchmark(compare: comparison, fuel_type: @fuel_type)
      end

      def holiday_usage
        @holiday_usage ||= holiday_usage_calculation_service.school_holiday_calendar_comparison
      end

      private

      def aggregate_meter
        aggregate_school.aggregate_meter(@fuel_type)
      end

      def aggregate_school
        @aggregate_school_service.meter_collection
      end

      def annual_usage_breakdown_service
        @annual_usage_breakdown_service ||= Usage::UsageBreakdownService.new(
          meter_collection: aggregate_school,
          fuel_type: @fuel_type
        )
      end

      def holiday_usage_calculation_service
        @holiday_usage_calculation_service ||= Usage::HolidayUsageCalculationService.new(
          aggregate_meter,
          aggregate_school.holidays
        )
      end
    end
  end
end

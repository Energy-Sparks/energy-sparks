module Schools
  module Advice
    class LongTermUsageService
      include AnalysableMixin

      def initialize(school, meter_collection, fuel_type)
        @school = school
        @meter_collection = meter_collection
        @fuel_type = fuel_type
      end

      def enough_data?
        annual_usage_calculator.enough_data?
      end

      def data_available_from
        annual_usage_calculator.data_available_from
      end

      def annual_usage
        annual_usage_calculator.annual_usage
      end

      def annual_usage_vs_benchmark(compare: :benchmark_school)
        annual_usage_benchmark.annual_usage(compare: compare)
      end

      def estimated_savings(versus: :benchmark_school)
        annual_usage_benchmark.estimated_savings(versus: versus)
      end

      def annual_usage_meter_breakdown
        meter_breakdown_service.calculate_breakdown
      end

      private

      def aggregate_meter
        @meter_collection.aggregate_meter(@fuel_type)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(@meter_collection, @fuel_type)
      end

      def annual_usage_calculator
        @annual_usage_calculator ||= Usage::AnnualUsageCalculationService.new(aggregate_meter, analysis_date)
      end

      def annual_usage_benchmark
        @annual_usage_benchmark ||= Usage::AnnualUsageBenchmarksService.new(@meter_collection, @fuel_type, analysis_date)
      end

      def meter_breakdown_service
        @meter_breakdown_service ||= Usage::AnnualUsageMeterBreakdownService.new(@meter_collection, @fuel_type, analysis_date)
      end
    end
  end
end

module Schools
  module Advice
    class LongTermUsageService
      include AnalysableMixin

      def initialize(school, aggregate_school_service, fuel_type)
        @school = school
        @aggregate_school_service = aggregate_school_service
        @fuel_type = fuel_type
      end

      def enough_data?
        usage_calculator.at_least_x_days_data?(90)
      end

      def data_available_from
        usage_calculator.date_when_enough_data_available(90)
      end

      def date_when_one_years_data
        usage_calculator.data_available_from
      end

      delegate :annual_usage, to: :usage_calculator
      delegate :annual_usage_change_since_last_year, to: :usage_calculator
      delegate :dates_for_period, to: :usage_calculator
      delegate :usage_change_since_last_period, to: :usage_calculator

      def annual_usage_kwh(compare: :benchmark_school)
        annual_usage_benchmark.annual_usage_kwh(compare: compare)
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

      def benchmark_usage
        annual_usage_kwh = annual_usage.kwh
        annual_usage_kwh_benchmark = annual_usage_kwh(compare: :benchmark_school)
        annual_usage_kwh_exemplar = annual_usage_kwh(compare: :exemplar_school)

        Schools::Comparison.new(
          school_value: annual_usage_kwh,
          benchmark_value: annual_usage_kwh_benchmark,
          exemplar_value: annual_usage_kwh_exemplar,
          unit: :kwh
        )
      end

      private

      def aggregate_meter
        meter_collection.aggregate_meter(@fuel_type)
      end

      def analysis_date
        AggregateSchoolService.analysis_date(meter_collection, @fuel_type)
      end

      def usage_calculator
        @usage_calculator ||= Usage::CalculationService.new(aggregate_meter, analysis_date)
      end

      def annual_usage_benchmark
        @annual_usage_benchmark ||= Usage::AnnualUsageBenchmarksService.new(meter_collection, @fuel_type, analysis_date)
      end

      def meter_breakdown_service
        @meter_breakdown_service ||= Usage::AnnualUsageMeterBreakdownService.new(meter_collection, @fuel_type, analysis_date)
      end

      def meter_collection
        @aggregate_school_service.meter_collection
      end
    end
  end
end

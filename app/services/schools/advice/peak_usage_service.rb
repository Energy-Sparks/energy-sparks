module Schools
  module Advice
    class PeakUsageService
      include AnalysableMixin
      # matches the required days for base load advice pages - see BaseloadService and Baseload::BaseService it uses
      REQUIRED_DAYS = 14

      def initialize(school, aggregate_school_service)
        @school = school
        @aggregate_school_service = aggregate_school_service
      end

      def enough_data?
        meter_data_checker.at_least_x_days_data?(REQUIRED_DAYS)
      end

      def data_available_from
        meter_data_checker.date_when_enough_data_available(REQUIRED_DAYS)
      end

      delegate :average_peak_kw, to: :peak_usage_calculation_service
      delegate :date_range, to: :peak_usage_calculation_service

      def previous_year_peak_kw
        previous_years_asof_date = asof_date - 1.year
        previous_years_checker = Util::MeterDateRangeChecker.new(aggregate_meter, previous_years_asof_date)
        return unless previous_years_checker.at_least_x_days_data?(REQUIRED_DAYS)

        previous_years_peak_usage_calculation_service = peak_usage_calculation_service(previous_years_asof_date)
        previous_years_peak_usage_calculation_service.average_peak_kw
      end

      def percentage_change_in_peak_kw
        percent_change(previous_year_peak_kw, average_peak_kw)
      end

      def benchmark_peak_usage
        Schools::Comparison.new(
          school_value: average_peak_kw,
          benchmark_value: peak_usage_benchmarking_service.average_peak_usage_kw(compare: :benchmark_school),
          exemplar_value: peak_usage_benchmarking_service.average_peak_usage_kw(compare: :exemplar_school),
          unit: :kw
        )
      end

      def asof_date
        @asof_date ||= AggregateSchoolService.analysis_date(meter_collection, :electricity)
      end

      private

      def meter_data_checker
        @meter_data_checker ||= Util::MeterDateRangeChecker.new(aggregate_meter, @asof_date)
      end

      # Copied from ContentBase
      def percent_change(old_value, new_value)
        return nil if old_value.nil? || new_value.nil?
        return 0.0 if !old_value.nan? && old_value == new_value # both 0.0 case

        (new_value - old_value) / old_value
      end

      def aggregate_meter
        meter_collection.aggregated_electricity_meters
      end

      def peak_usage_benchmarking_service
        @peak_usage_benchmarking_service ||= ::Usage::PeakUsageBenchmarkingService.new(
          meter_collection: meter_collection,
          asof_date: asof_date
        )
      end

      def peak_usage_calculation_service(date = asof_date)
        Usage::PeakUsageCalculationService.new(meter_collection: meter_collection, asof_date: date)
      end

      def meter_collection
        @aggregate_school_service.meter_collection
      end
    end
  end
end

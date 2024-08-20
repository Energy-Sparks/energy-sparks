module Schools
  module Advice
    class BaseLongTermController < AdviceBaseController
      def insights
        @analysis_dates = analysis_dates
        @annual_usage = usage_service.annual_usage
        @annual_usage_change_since_last_year = usage_service.annual_usage_change_since_last_year
        @benchmarked_usage = usage_service.benchmark_usage
      end

      def analysis
        @analysis_dates = analysis_dates

        @annual_usage = usage_service.annual_usage
        @vs_benchmark = usage_service.annual_usage_vs_benchmark(compare: :benchmark_school)
        @vs_exemplar = usage_service.annual_usage_vs_benchmark(compare: :exemplar_school)

        @estimated_savings_vs_exemplar = usage_service.estimated_savings(versus: :exemplar_school)
        @estimated_savings_vs_benchmark = usage_service.estimated_savings(versus: :benchmark_school)

        @meter_selection = Charts::MeterSelection.new(@school, aggregate_school, advice_page_fuel_type, date_window: 363)
      end

      private

      def last_full_week_start_date(end_date)
        if one_years_data?(analysis_start_date, analysis_end_date)
          end_date.prev_year.end_of_week
        else
          analysis_start_date.end_of_week
        end
      end

      def multiple_meters?
        @school.meters.active.where(meter_type: fuel_type).count > 1
      end

      def create_analysable
        usage_service
      end

      def analysis_dates
        dates = super
        dates.date_when_one_years_data = usage_service.date_when_one_years_data
        dates
      end

      def usage_service
        @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
      end
    end
  end
end

module Schools
  module Advice
    class BaseloadController < AdviceController
      include AdvicePages

      def show
        redirect_to insights_school_advice_baseload_path(@school)
      end

      def insights
      end

      def analysis
        @start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        @end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
        @multiple_meters = @school.meters.electricity.count > 1

        @baseload_usage = baseload_usage(aggregate_school, @end_date)
        @benchmark_usage = benchmark_usage(aggregate_school, @end_date)
        @estimated_savings = estimated_savings(aggregate_school, @end_date)
        @annual_average_baseloads = annual_average_baseloads(aggregate_school, @start_date, @end_date)
        @baseload_meter_breakdown = baseload_meter_breakdown(aggregate_school, @end_date)

        @seasonal_variation = seasonal_variation(aggregate_school, @end_date)
        @seasonal_variation_by_meter = seasonal_variation_by_meter(aggregate_school)

        @intraweek_variation = intraweek_variation(aggregate_school, @end_date)
        @intraweek_variation_by_meter = intraweek_variation_by_meter(aggregate_school)
      end

      private

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end

module Schools
  module Advice
    class BaseloadController < AdviceBaseController
      def insights
      end

      def analysis
        baseload_service = Schools::Advice::BaseloadService.new(@school, aggregate_school)
        @meters = @school.meters.electricity
        @start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        @end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
        @multiple_meters = baseload_service.multiple_electricity_meters?
        @average_baseload_kw = baseload_service.average_baseload_kw
        @average_baseload_kw_benchmark = baseload_service.average_baseload_kw_benchmark
        @baseload_usage = baseload_service.annual_baseload_usage
        @benchmark_usage = baseload_service.baseload_usage_benchmark
        @estimated_savings = baseload_service.estimated_savings
        @annual_average_baseloads = baseload_service.annual_average_baseloads
        if @multiple_meters
          @baseload_meter_breakdown = baseload_service.baseload_meter_breakdown
          @baseload_meter_breakdown_total = baseload_service.meter_breakdown_table_total
        end

        @seasonal_variation = baseload_service.seasonal_variation
        @seasonal_variation_by_meter = baseload_service.seasonal_variation_by_meter
        @intraweek_variation = baseload_service.intraweek_variation
        @intraweek_variation_by_meter = baseload_service.intraweek_variation_by_meter
      end

      private

      def advice_page_key
        :baseload
      end
    end
  end
end

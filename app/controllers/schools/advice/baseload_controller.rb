module Schools
  module Advice
    class BaseloadController < AdviceBaseController
      include AdvicePageHelper
      def insights
        @start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        @end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date

        baseload_service = baseload_service(aggregate_school)
        @average_baseload_kw_last_year = baseload_service.average_baseload_kw(period: :year)
        @average_baseload_kw_last_week = baseload_service.average_baseload_kw(period: :week)

        @previous_year_average_baseload_kw = baseload_service.previous_period_average_baseload_kw(period: :year)
        @percentage_change_year = relative_percent(@previous_year_average_baseload_kw, @average_baseload_kw_last_year)

        @previous_week_average_baseload_kw = baseload_service.previous_period_average_baseload_kw(period: :week)
        @percentage_change_week = relative_percent(@previous_week_average_baseload_kw, @average_baseload_kw_last_week)

        @average_baseload_kw_benchmark = baseload_service.average_baseload_kw_benchmark(compare: :benchmark_school)
        @average_baseload_kw_exemplar = baseload_service.average_baseload_kw_benchmark(compare: :exemplar_school)
        @category = categorise_school_vs_benchmark(@average_baseload_kw_last_year, @average_baseload_kw_benchmark, @average_baseload_kw_exemplar)
      end

      def analysis
        baseload_service = baseload_service(aggregate_school)
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

      def baseload_service(aggregate_school)
        @baseload_service ||= Schools::Advice::BaseloadService.new(@school, aggregate_school)
      end

      def advice_page_key
        :baseload
      end
    end
  end
end

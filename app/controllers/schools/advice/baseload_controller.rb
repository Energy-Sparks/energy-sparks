module Schools
  module Advice
    class BaseloadController < AdviceController
      def show
        redirect_to insights_school_advice_baseload_path(@school)
      end

      def insights
      end

      def analysis
        @start_date = aggregate_school.aggregated_electricity_meters.amr_data.start_date
        @end_date = aggregate_school.aggregated_electricity_meters.amr_data.end_date
        @multiple_meters = @school.meters.electricity.count > 1

        baseload_service = Baseload::BaseloadCalculationService.new(aggregate_school.aggregated_electricity_meters, @end_date)
        @baseload_usage = baseload_service.annual_baseload_usage

        benchmark_service = Baseload::BaseloadBenchmarkingService.new(aggregate_school, @end_date)
        @benchmark_usage = benchmark_service.baseload_usage
        @estimated_savings = benchmark_service.estimated_savings

        @annual_average_baseloads = annual_average_baseloads(@start_date, @end_date)

        baseload_meter_breakdown_service = Baseload::BaseloadMeterBreakdownService.new(aggregate_school)
        @baseload_meter_breakdown = baseload_meter_breakdown_service.calculate_breakdown

        seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(aggregate_school.aggregated_electricity_meters, @end_date)
        @seasonal_baseload_variation = seasonal_baseload_service.seasonal_variation

        @seasonal_baseload_variation_by_meter = {}
        if @multiple_meters
          aggregate_school.electricity_meters.each do |meter|
            seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(meter, meter.amr_data.end_date)
            @seasonal_baseload_variation_by_meter[meter.mpan_mprn] = seasonal_baseload_service.seasonal_variation
          end
        end

        intraweek_baseload_service = Baseload::IntraweekBaseloadService.new(aggregate_school.aggregated_electricity_meters, @end_date)
        @intraweek_variation = intraweek_baseload_service.intraweek_variation
      end

      private

      def annual_average_baseloads(start_date, end_date)
        (start_date.year..end_date.year).map do |year|
          end_of_year = Date.new(year).end_of_year
          baseload_service = Baseload::BaseloadCalculationService.new(aggregate_school.aggregated_electricity_meters, end_of_year)
          {
            year: year,
            baseload_usage: baseload_service.annual_baseload_usage
          }
        end
      end

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end

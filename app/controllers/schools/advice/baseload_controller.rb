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

        @baseload_usage = baseload_usage(aggregate_school, @end_date)
        @benchmark_usage = benchmark_usage(aggregate_school, @end_date)
        @estimated_savings = estimated_savings(aggregate_school, @end_date)
        @annual_average_baseloads = annual_average_baseloads(aggregate_school, @start_date, @end_date)
        @baseload_meter_breakdown = baseload_meter_breakdown(aggregate_school)

        @seasonal_variation = seasonal_variation(aggregate_school, @end_date)
        @seasonal_variation_by_meter = seasonal_variation_by_meter(aggregate_school)

        @intraweek_variation = intraweek_variation(aggregate_school, @end_date)
        @intraweek_variation_by_meter = intraweek_variation_by_meter(aggregate_school)
      end

      private

      def baseload_usage(meter_collection, end_date)
        baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_date)
        baseload_service.annual_baseload_usage
      end

      def benchmark_usage(meter_collection, end_date)
        benchmark_service = Baseload::BaseloadBenchmarkingService.new(meter_collection, end_date)
        benchmark_service.baseload_usage
      end

      def estimated_savings(meter_collection, end_date)
        benchmark_service = Baseload::BaseloadBenchmarkingService.new(meter_collection, end_date)
        benchmark_service.estimated_savings
      end

      def annual_average_baseloads(meter_collection, start_date, end_date)
        (start_date.year..end_date.year).map do |year|
          end_of_year = Date.new(year).end_of_year
          baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_of_year)
          {
            year: year,
            baseload_usage: baseload_service.annual_baseload_usage
          }
        end
      end

      def baseload_meter_breakdown(meter_collection)
        baseload_meter_breakdown_service = Baseload::BaseloadMeterBreakdownService.new(meter_collection)
        baseload_meter_breakdown_service.calculate_breakdown
      end

      def seasonal_variation(meter_collection, end_date)
        seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(meter_collection.aggregated_electricity_meters, end_date)
        variation = seasonal_baseload_service.seasonal_variation
        saving = seasonal_baseload_service.estimated_costs
        build_seasonal_variation(variation, saving)
      end

      def seasonal_variation_by_meter(meter_collection)
        variation_by_meter = {}
        if meter_collection.electricity_meters.count > 1
          meter_collection.electricity_meters.each do |meter|
            seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(meter, meter.amr_data.end_date)
            variation = seasonal_baseload_service.seasonal_variation
            saving = seasonal_baseload_service.estimated_costs
            variation_by_meter[meter.mpan_mprn] = build_seasonal_variation(variation, saving)
          end
        end
        variation_by_meter
      end

      def intraweek_variation(meter_collection, end_date)
        intraweek_baseload_service = Baseload::IntraweekBaseloadService.new(meter_collection.aggregated_electricity_meters, end_date)
        variation = intraweek_baseload_service.intraweek_variation
        saving = intraweek_baseload_service.estimated_costs
        build_intraweek_variation(variation, saving)
      end

      def intraweek_variation_by_meter(meter_collection)
        variation_by_meter = {}
        if meter_collection.electricity_meters.count > 1
          meter_collection.electricity_meters.each do |meter|
            intraweek_baseload_service = Baseload::IntraweekBaseloadService.new(meter, meter.amr_data.end_date)
            variation = intraweek_baseload_service.intraweek_variation
            saving = intraweek_baseload_service.estimated_costs
            variation_by_meter[meter.mpan_mprn] = build_intraweek_variation(variation, saving)
          end
        end
        variation_by_meter
      end

      def variation_rating(variation_percentage)
        calculate_rating_from_range(0, 0.50, variation_percentage.abs)
      end

      # from analytics: lib/dashboard/charting_and_reports/content_base.rb
      def calculate_rating_from_range(good_value, bad_value, actual_value)
        [10.0 * [(actual_value - bad_value) / (good_value - bad_value), 0.0].max, 10.0].min.round(1)
      end

      def build_seasonal_variation(variation, saving)
        OpenStruct.new(
          winter_kw: variation.winter_kw,
          summer_kw: variation.summer_kw,
          percentage: variation.percentage,
          estimated_saving_£: saving.£,
          estimated_saving_co2: saving.co2,
          variation_rating: variation_rating(variation.percentage)
        )
      end

      def build_intraweek_variation(variation, saving)
        OpenStruct.new(
          max_day_kw: variation.max_day_kw,
          min_day_kw: variation.min_day_kw,
          percent_intraday_variation: variation.percent_intraday_variation,
          estimated_saving_£: saving.£,
          estimated_saving_co2: saving.co2,
          variation_rating: variation_rating(variation.percent_intraday_variation)
        )
      end

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end

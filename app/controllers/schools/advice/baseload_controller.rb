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

      def baseload_meter_breakdown(meter_collection, end_date)
        baseload_meter_breakdown_service = Baseload::BaseloadMeterBreakdownService.new(meter_collection)
        baseloads = baseload_meter_breakdown_service.calculate_breakdown

        end_of_previous_year = end_date - 1.year
        meter_breakdowns = {}
        baseloads.meters.each do |mpan_mprn|
          #
          # find meter collection meter by mpan_mprn....
          #
          baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.meter?(mpan_mprn), end_of_previous_year)
          previous_year_baseload = baseload_service.average_baseload_kw
          meter_breakdowns[mpan_mprn] = build_meter_breakdown(mpan_mprn, baseloads, previous_year_baseload)
        end

        baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_of_previous_year)
        previous_year_baseload = baseload_service.average_baseload_kw
        meter_breakdowns['Total'] = build_meter_breakdown_totals(meter_breakdowns, previous_year_baseload)

        meter_breakdowns
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

      def load_advice_page
        @advice_page = AdvicePage.find_by_key(:baseload)
      end
    end
  end
end

# rubocop:disable Naming/AsciiIdentifiers
module Schools
  module Advice
    class BaseloadService < BaseService
      def has_electricity?
        @school.has_electricity?
      end

      def multiple_meters?
        @school.meters.electricity.count > 1
      end

      def average_baseload_kw(period: :year)
        @average_baseload_kw ||= baseload_service.average_baseload_kw(period: period)
      end

      #This could be pushed down into the underlying service
      #TODO cache results
      def previous_year_average_baseload_kw
        baseload_service = Baseload::BaseloadCalculationService.new(aggregate_meter, end_of_previous_year)
        @previous_year_average_baseload_kw ||= baseload_service.average_baseload_kw(period: :year)
      end

      def annual_baseload_usage
        @annual_baseload_usage ||= baseload_service.annual_baseload_usage
      end

      def average_baseload_kw_benchmark(compare: :benchmark_school)
        benchmark_service.average_baseload_kw(compare: compare)
      end

      def baseload_usage_benchmark(compare: :benchmark_school)
        benchmark_service.baseload_usage(compare: compare)
      end

      def estimated_savings(versus: :benchmark_school)
        benchmark_service.estimated_savings(versus: versus)
      end

      #Calculate the annual average baseload for every year
      def annual_average_baseloads
        start_date, end_date = date_range
        (start_date.year..end_date.year).map do |year|
          end_of_year = Date.new(year).end_of_year
          baseload_service = Baseload::BaseloadCalculationService.new(aggregate_meter, end_of_year)
          {
            year: year,
            baseload: baseload_service.average_baseload_kw(period: :year),
            baseload_usage: baseload_service.annual_baseload_usage
          }
        end
      end

      def baseload_meter_breakdown
        meter_breakdown_service = Baseload::BaseloadMeterBreakdownService.new(@meter_collection)
        baseloads = meter_breakdown_service.calculate_breakdown
        meter_breakdowns = {}
        baseloads.meters.each do |mpan_mprn|
          baseload_service = Baseload::BaseloadCalculationService.new(@meter_collection.meter?(mpan_mprn), end_of_previous_year)
          previous_year_baseload = baseload_service.average_baseload_kw(period: :year)
          meter_breakdowns[mpan_mprn] = build_meter_breakdown(mpan_mprn, baseloads, previous_year_baseload)
        end
        meter_breakdowns
      end

      #helper for building "all meters" / total row for meter breakdown table
      def meter_breakdown_table_total
        baseload_usage = annual_baseload_usage
        previous_year_baseload = previous_year_average_baseload_kw
        baseload_kw = average_baseload_kw
        OpenStruct.new(
          baseload_kw: baseload_kw,
          baseload_cost_£: baseload_usage.£,
          percentage_baseload: 1.0,
          baseload_previous_year_kw: previous_year_baseload,
          baseload_change_kw: baseload_kw - previous_year_baseload
        )
      end

      def seasonal_variation
        calculate_seasonal_variation(aggregate_meter, asof_date)
      end

      def seasonal_variation_by_meter
        variation_by_meter = {}
        if @meter_collection.electricity_meters.count > 1
          @meter_collection.electricity_meters.each do |meter|
            variation_by_meter[meter.mpan_mprn] = calculate_seasonal_variation(meter, meter.amr_data.end_date, true)
          end
        end
        variation_by_meter
      end

      def intraweek_variation
        calculate_intraweek_variation(aggregate_meter, asof_date)
      end

      def intraweek_variation_by_meter
        variation_by_meter = {}
        if @meter_collection.electricity_meters.count > 1
          @meter_collection.electricity_meters.each do |meter|
            variation_by_meter[meter.mpan_mprn] = calculate_intraweek_variation(meter, meter.amr_data.end_date, true)
          end
        end
        variation_by_meter
      end

      private

      def asof_date
        @asof_date ||= date_range[1]
      end

      def end_of_previous_year
        @end_of_previous_year ||= asof_date - 1.year
      end

      def aggregate_meter
        @meter_collection.aggregated_electricity_meters
      end

      def baseload_service
        @baseload_service ||= Baseload::BaseloadCalculationService.new(aggregate_meter, asof_date)
      end

      def benchmark_service
        @benchmark_service ||= Baseload::BaseloadBenchmarkingService.new(@meter_collection, asof_date)
      end

      def build_meter_breakdown(mpan_mprn, breakdown, previous_year_baseload)
        OpenStruct.new(
          meter: meter_for_mpan(mpan_mprn),
          baseload_kw: breakdown.baseload_kw(mpan_mprn),
          baseload_cost_£: breakdown.baseload_cost_£(mpan_mprn),
          percentage_baseload: breakdown.percentage_baseload(mpan_mprn),
          baseload_previous_year_kw: previous_year_baseload,
          baseload_change_kw: breakdown.baseload_kw(mpan_mprn) - previous_year_baseload
        )
      end

      def calculate_seasonal_variation(meter = aggregate_meter, date = asof_date, load_meter = false)
        seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(meter, date)
        variation = seasonal_baseload_service.seasonal_variation
        saving = seasonal_baseload_service.estimated_costs
        meter = load_meter ? meter_for_mpan(meter.mpan_mprn) : nil
        build_seasonal_variation(meter, variation, saving)
      end

      def build_seasonal_variation(meter, variation, saving)
        OpenStruct.new(
          meter: meter,
          winter_kw: variation.winter_kw,
          summer_kw: variation.summer_kw,
          percentage: variation.percentage,
          estimated_saving_£: saving.£,
          estimated_saving_co2: saving.co2,
          variation_rating: seasonal_variation_rating(variation.percentage)
        )
      end

      def seasonal_variation_rating(percentage)
        calculate_rating_from_range(0, 0.50, percentage)
      end

      def calculate_intraweek_variation(meter = aggregate_meter, date = asof_date, load_meter = false)
        intraweek_baseload_service = Baseload::IntraweekBaseloadService.new(meter, date)
        variation = intraweek_baseload_service.intraweek_variation
        saving = intraweek_baseload_service.estimated_costs
        meter = load_meter ? meter_for_mpan(meter.mpan_mprn) : nil
        build_intraweek_variation(meter, variation, saving)
      end

      def build_intraweek_variation(meter, variation, saving)
        OpenStruct.new(
          meter: meter,
          max_day_kw: variation.max_day_kw,
          min_day_kw: variation.min_day_kw,
          percent_intraday_variation: variation.percent_intraday_variation,
          estimated_saving_£: saving.£,
          estimated_saving_co2: saving.co2,
          variation_rating: intraweek_variation_rating(variation.percent_intraday_variation)
        )
      end

      def intraweek_variation_rating(percentage)
        calculate_rating_from_range(0.1, 0.3, percentage)
      end
    end
  end
end
# rubocop:enable Naming/AsciiIdentifiers

# rubocop:disable Naming/AsciiIdentifiers
module Schools
  module Advice
    class BaseloadService < BaseService
      include AnalysableMixin

      def enough_data?
        baseload_service.enough_data?
      end

      def data_available_from
        baseload_service.data_available_from
      end

      def has_electricity?
        @school.has_electricity?
      end

      def multiple_electricity_meters?
        electricity_meters.count > 1
      end

      def average_baseload_kw(period: :year)
        @average_baseloads_period ||= {}
        @average_baseloads_period[period] ||= baseload_service.average_baseload_kw(period: period)
      end

      def previous_period_average_baseload_kw(period: :year)
        case period
        when :year
          baseload_service = Baseload::BaseloadCalculationService.new(aggregate_meter, end_of_previous_year)
          @previous_year_average_baseload_kw ||= baseload_service.average_baseload_kw(period: period)
        when :week
          baseload_service = Baseload::BaseloadCalculationService.new(aggregate_meter, end_of_previous_week)
          @previous_week_average_baseload_kw ||= baseload_service.average_baseload_kw(period: period)
        else
          raise "Invalid period"
        end
      end

      def saving_through_1_kw_reduction_in_baseload
        baseload_service.saving_through_1_kw_reduction_in_baseload
      end

      def annual_baseload_usage
        @annual_baseload_usage ||= baseload_service.annual_baseload_usage(include_percentage: true)
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
        start_date = aggregate_meter.amr_data.start_date
        end_date = aggregate_meter.amr_data.end_date
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
        previous_year_baseload = previous_period_average_baseload_kw(period: :year)
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
        return {} unless electricity_meters.count > 1
        electricity_meters.each_with_object({}) do |meter, variation_by_meter|
          variation_by_meter[meter.mpan_mprn] = calculate_seasonal_variation(meter, meter.amr_data.end_date, true)
        end
      end

      def intraweek_variation
        calculate_intraweek_variation(aggregate_meter, asof_date)
      end

      def intraweek_variation_by_meter
        return {} unless electricity_meters.count > 1
        electricity_meters.each_with_object({}) do |meter, variation_by_meter|
          variation_by_meter[meter.mpan_mprn] = calculate_intraweek_variation(meter, meter.amr_data.end_date, true)
        end
      end

      def date_ranges_by_meter
        electricity_meters.each_with_object({}) do |analytics_meter, date_range_by_meter|
          end_date = analytics_meter.amr_data.end_date
          start_date = analytics_meter.amr_data.start_date
          meter = @school.meters.find_by_mpan_mprn(analytics_meter.mpan_mprn)
          date_range_by_meter[analytics_meter.mpan_mprn] = {
            meter: meter,
            start_date: start_date,
            end_date: end_date
          }
        end
      end

      def benchmark_baseload
        average_baseload_kw_last_year = average_baseload_kw(period: :year)
        average_baseload_kw_benchmark = average_baseload_kw_benchmark(compare: :benchmark_school)
        average_baseload_kw_exemplar = average_baseload_kw_benchmark(compare: :exemplar_school)

        Schools::Comparison.new(
          school_value: average_baseload_kw_last_year,
          benchmark_value: average_baseload_kw_benchmark,
          exemplar_value: average_baseload_kw_exemplar,
          unit: :kw
        )
      end

      private

      def asof_date
        @asof_date ||= aggregate_meter.amr_data.end_date
      end

      #the ElectricityBaseloadAnalysis class defines one_week_ago as
      #6 days before the calculation date. So when we calculate last weeks
      #baseload is asof_date - 6. This is apparently to address some issues
      #with large intraweek variation.
      #
      #So for our comparison of last week and previous week, we want a week
      #before that which is 13 days...
      def end_of_previous_week
        asof_date - 13
      end

      def end_of_previous_year
        @end_of_previous_year ||= asof_date - 1.year
      end

      def electricity_meters
        @electricity_meters ||= @meter_collection.electricity_meters
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

      def calculate_seasonal_variation(analytics_meter = aggregate_meter, date = asof_date, load_meter = false)
        meter = load_meter ? meter_for_mpan(analytics_meter.mpan_mprn) : nil
        seasonal_baseload_service = Baseload::SeasonalBaseloadService.new(analytics_meter, date)
        #return if there's not enough data, then return limited object
        return OpenStruct.new(meter: meter, enough_data?: false, data_available_from: seasonal_baseload_service.data_available_from) unless seasonal_baseload_service.enough_data?
        variation = seasonal_baseload_service.seasonal_variation
        #we may have >1 year of data, but not enough to actually calculate a seasonal analysis
        #e.g. a meter for a swimming pool only used in the summer
        return OpenStruct.new(meter: meter, enough_data?: false) if variation.percentage.nan?
        saving = seasonal_baseload_service.estimated_costs
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
          variation_rating: seasonal_variation_rating(variation.percentage),
          enough_data?: true
        )
      end

      def seasonal_variation_rating(percentage)
        calculate_rating_from_range(0, 0.50, percentage)
      end

      def calculate_intraweek_variation(analytics_meter = aggregate_meter, date = asof_date, load_meter = false)
        intraweek_baseload_service = Baseload::IntraweekBaseloadService.new(analytics_meter, date)
        meter = load_meter ? meter_for_mpan(analytics_meter.mpan_mprn) : nil
        return OpenStruct.new(meter: meter, enough_data?: false, data_available_from: intraweek_baseload_service.data_available_from) unless intraweek_baseload_service.enough_data?
        variation = intraweek_baseload_service.intraweek_variation
        saving = intraweek_baseload_service.estimated_costs
        build_intraweek_variation(meter, variation, saving)
      end

      def build_intraweek_variation(meter, variation, saving)
        OpenStruct.new(
          meter: meter,
          max_day: variation.max_day,
          min_day: variation.min_day,
          max_day_kw: variation.max_day_kw,
          min_day_kw: variation.min_day_kw,
          percent_intraday_variation: variation.percent_intraday_variation,
          estimated_saving_£: saving.£,
          estimated_saving_co2: saving.co2,
          variation_rating: intraweek_variation_rating(variation.percent_intraday_variation),
          enough_data?: true
        )
      end

      def intraweek_variation_rating(percentage)
        calculate_rating_from_range(0.1, 0.3, percentage)
      end
    end
  end
end
# rubocop:enable Naming/AsciiIdentifiers

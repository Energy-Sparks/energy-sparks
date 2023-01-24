module AdvicePages
  extend ActiveSupport::Concern

  # from analytics: lib/dashboard/charting_and_reports/content_base.rb
  def calculate_rating_from_range(good_value, bad_value, actual_value)
    actual_value = actual_value.abs
    [10.0 * [(actual_value - bad_value) / (good_value - bad_value), 0.0].max, 10.0].min.round(1)
  end

  def build_meter_breakdown(mpan_mprn, breakdown, previous_year_baseload)
    OpenStruct.new(
      baseload_kw: breakdown.baseload_kw(mpan_mprn),
      baseload_cost_£: breakdown.baseload_cost_£(mpan_mprn),
      percentage_baseload: breakdown.percentage_baseload(mpan_mprn),
      baseload_previous_year_kw: previous_year_baseload,
      baseload_change_kw: breakdown.baseload_kw(mpan_mprn) - previous_year_baseload
    )
  end

  def build_meter_breakdown_total(meter_collection, end_date)
    baseload_usage = baseload_usage(meter_collection, end_date)
    previous_year_baseload = previous_year_baseload_kw(meter_collection, end_date)
    baseload_kw = average_baseload_kw(meter_collection, end_date)
    OpenStruct.new(
      baseload_kw: baseload_kw,
      baseload_cost_£: baseload_usage.£,
      percentage_baseload: 1.0,
      baseload_previous_year_kw: previous_year_baseload,
      baseload_change_kw: baseload_kw - previous_year_baseload
    )
  end

  def build_seasonal_variation(variation, saving)
    OpenStruct.new(
      winter_kw: variation.winter_kw,
      summer_kw: variation.summer_kw,
      percentage: variation.percentage,
      estimated_saving_£: saving.£,
      estimated_saving_co2: saving.co2,
      variation_rating: calculate_rating_from_range(0, 0.50, variation.percentage)
    )
  end

  def build_intraweek_variation(variation, saving)
    OpenStruct.new(
      max_day_kw: variation.max_day_kw,
      min_day_kw: variation.min_day_kw,
      percent_intraday_variation: variation.percent_intraday_variation,
      estimated_saving_£: saving.£,
      estimated_saving_co2: saving.co2,
      variation_rating: calculate_rating_from_range(0.1, 0.3, variation.percent_intraday_variation)
    )
  end

  def average_baseload_kw(meter_collection, end_date, period: :year)
    baseload_service(meter_collection, end_date).average_baseload_kw(period: period)
  end

  def average_baseload_kw_benchmark(meter_collection, end_date, compare: :benchmark_school)
    benchmark_service(meter_collection, end_date).average_baseload_kw(compare: compare)
  end

  def baseload_usage(meter_collection, end_date)
    baseload_service(meter_collection, end_date).annual_baseload_usage
  end

  def benchmark_usage(meter_collection, end_date)
    benchmark_service(meter_collection, end_date).baseload_usage
  end

  def estimated_savings(meter_collection, end_date)
    benchmark_service(meter_collection, end_date).estimated_savings
  end

  def annual_average_baseloads(meter_collection, start_date, end_date)
    (start_date.year..end_date.year).map do |year|
      end_of_year = Date.new(year).end_of_year
      baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_of_year)
      {
        year: year,
        baseload: baseload_service.average_baseload_kw(period: :year),
        baseload_usage: baseload_service.annual_baseload_usage
      }
    end
  end

  def previous_year_baseload_kw(meter_collection, end_date)
    end_of_previous_year = end_date - 1.year
    baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_of_previous_year)
    baseload_service.average_baseload_kw
  end

  def baseload_meter_breakdown(meter_collection, end_date)
    baseload_meter_breakdown_service = Baseload::BaseloadMeterBreakdownService.new(meter_collection)
    baseloads = baseload_meter_breakdown_service.calculate_breakdown

    end_of_previous_year = end_date - 1.year
    meter_breakdowns = {}
    baseloads.meters.each do |mpan_mprn|
      baseload_service = Baseload::BaseloadCalculationService.new(meter_collection.meter?(mpan_mprn), end_of_previous_year)
      previous_year_baseload = baseload_service.average_baseload_kw
      meter_breakdowns[mpan_mprn] = build_meter_breakdown(mpan_mprn, baseloads, previous_year_baseload)
    end
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

  def baseload_service(meter_collection, end_date)
    @baseload_service ||= Baseload::BaseloadCalculationService.new(meter_collection.aggregated_electricity_meters, end_date)
  end

  def benchmark_service(meter_collection, end_date)
    @benchmark_service ||= Baseload::BaseloadBenchmarkingService.new(meter_collection, end_date)
  end
end

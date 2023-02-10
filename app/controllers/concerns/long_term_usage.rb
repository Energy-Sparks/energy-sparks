module LongTermUsage
  extend ActiveSupport::Concern

  def fuel_type
    :electricity
  end

  def multiple_meters?
    @school.meters.active.where(meter_type: fuel_type).count > 1
  end

  def aggregate_meter
    aggregate_school.aggregated_electricity_meters
  end

  def create_analysable
    usage_service
  end

  def sorted_meters_for_breakdown(annual_usage_meter_breakdown)
    meters = @school.meters.where(mpan_mprn: annual_usage_meter_breakdown.meters).order(:name, :mpan_mprn)
    meters.index_by(&:mpan_mprn)
  end

  def analysis_dates
    start_date = aggregate_meter.amr_data.start_date
    end_date = aggregate_meter.amr_data.end_date
    OpenStruct.new(
      start_date: start_date,
      end_date: end_date,
      one_year_before_end: end_date - 1.year,
      last_full_week_start_date: last_full_week_start_date(end_date),
      last_full_week_end_date: last_full_week_end_date(end_date),
      one_years_data: one_years_data?(start_date, end_date),
      months_of_data: months_between(start_date, end_date),
      recent_data: recent_data?(end_date)
    )
  end

  #for charts that use the last full week
  def last_full_week_start_date(end_date)
    end_date.prev_year.end_of_week
  end

  #for charts that use the last full week
  def last_full_week_end_date(end_date)
    end_date.prev_week.end_of_week - 1
  end

  def benchmarked_usage(annual_usage_kwh)
    annual_usage_kwh_benchmark = usage_service.annual_usage_kwh(compare: :benchmark_school)
    annual_usage_kwh_exemplar = usage_service.annual_usage_kwh(compare: :exemplar_school)

    OpenStruct.new(
      category: categorise_school_vs_benchmark(annual_usage_kwh, annual_usage_kwh_benchmark, annual_usage_kwh_exemplar),
      annual_usage_kwh: annual_usage_kwh,
      annual_usage_kwh_benchmark: annual_usage_kwh_benchmark,
      annual_usage_kwh_exemplar: annual_usage_kwh_exemplar
    )
  end

  def usage_service
    @usage_service ||= Schools::Advice::LongTermUsageService.new(@school, aggregate_school, fuel_type)
  end
end

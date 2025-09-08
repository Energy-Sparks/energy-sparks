# Uses the charting aggregation engine to calculate single aggregate values
# (e.g. kWh, CO2, economic cost or accounting cost ) over a given time period
# (e.g. :week, :month, :year)
#
# Configures a pseudo chart config to tell aggregation
# engine what to do
class CalculateAggregateValues
  def initialize(meter_collection)
    @meter_collection = meter_collection
  end

  def value(time_scale, fuel_type, data_type, sync_energy_data_time_scales = true)
    case fuel_type
    when :energy_ex_solar
      aggregate_multiple_fuel_types(time_scale, @meter_collection.fuel_types, data_type, sync_energy_data_time_scales)
    when :energy
      fuel_types = @meter_collection.fuel_types + [:solar_pv] if @meter_collection.solar_pv_panels?
      aggregate_multiple_fuel_types(time_scale, fuel_types, data_type, sync_energy_data_time_scales)
    else
      aggregate_value(time_scale, fuel_type, data_type)
    end
  end

  def scalar(time_scale, fuel_type, data_type, override = nil)
    (value, start_date, end_date) = aggregate_value_with_dates(time_scale, fuel_type, data_type, override)
    meter = @meter_collection.aggregate_meter(fuel_type)
    floor_area       = meter.meter_floor_area(      @meter_collection, start_date, end_date)
    number_of_pupils = meter.meter_number_of_pupils(@meter_collection, start_date, end_date)
    {
      value:                value,
      start_date:           start_date,
      end_date:             end_date,
      floor_area:           floor_area,
      number_of_pupils:     number_of_pupils,
      value_per_floor_area: value / floor_area,
      value_per_pupil:      value / number_of_pupils,
      time_scale:           time_scale,
      fuel_type:            fuel_type,
      datatype:             data_type
    }
  end

  def aggregate_value(time_scale, fuel_type, data_type = :kwh, override = nil, max_days_out_of_date = nil)
    check_data_available_for_fuel_type(fuel_type)
    aggregation_configuration(time_scale, fuel_type, data_type, override, false, max_days_out_of_date)
  end

  def aggregate_value_with_dates(time_scale, fuel_type, data_type = :kwh, override = nil)
    check_data_available_for_fuel_type(fuel_type)
    aggregation_configuration(time_scale, fuel_type, data_type, override, true)
  end

  def uk_electricity_grid_carbon_intensity_for_period_kg_per_kwh(time_scale)
    kwh = aggregation_configuration(time_scale, :electricity, :kwh)
    co2 = aggregation_configuration(time_scale, :electricity, :co2)
    co2 / kwh
  end

  def day_type_breakdown(time_scale, fuel_type, data_type = :kwh, format_data = false, percent = false)
    aggregator = generic_aggregation_calculation(time_scale, fuel_type, data_type, {series_breakdown: :daytype})
    extract_data_from_chart_calculation_result(aggregator, percent, data_type, format_data)
  end

  def aggregation_configuration(timescales, fuel_type, data_type, override = nil, with_dates = false, max_days_out_of_date = nil)
    results = non_contiguous_timescale_breakdown(timescales).map do |timescale|
      aggregate_one_timescale(timescale, fuel_type, data_type, override, max_days_out_of_date)
    end
    # ap results
    # map then sum to avoid statsample bug
    value      = results.map{ |result| result[:value]       }.sum
    start_date = results.map{ |result| result[:start_date]  }.min
    end_date   = results.map{ |result| result[:end_date]    }.max

    with_dates ? [value, start_date, end_date] : value
  end

  private

  def aggregate_multiple_fuel_types(time_scale, fuel_types, data_type, sync_energy_data_time_scales = true)
    asof_date = sync_energy_data_time_scales ? { asof_date: @meter_collection.last_combined_meter_date } : nil
    total = fuel_types.map do |fuel_type|
      aggregate_but_nan_if_not_enough_data(time_scale, fuel_type, data_type, asof_date)
    end.sum # map then sum to avoid statsample .sum bug
    nan_to_nil(total)
  end

  def aggregate_but_nan_if_not_enough_data(time_scale, fuel_type, data_type, override = nil)
    begin
      aggregate_value(time_scale, fuel_type, data_type, override)
    rescue EnergySparksNotEnoughDataException => _e
      Float::NAN
    end
  end

  def nan_to_nil(val)
    val.nan? ? nil : val
  end

  def extract_data_from_chart_calculation_result(aggregator, percent, data_type, format_data)
    data = aggregator.bucketed_data
    data.transform_values! { |v| v[0] }
    total = data.values.sum if percent
    data.transform_values! { |v| v / total } if percent
    format_unit_type = percent ? :percent : data_type
    data.transform_values! { |v| FormatEnergyUnit.format(format_unit_type, v) } if format_data
    data
  end

  def aggregate_one_timescale(timescale, fuel_type, data_type, override, max_days_out_of_date)
    aggregator = generic_aggregation_calculation(timescale, fuel_type, data_type, override)
    dates = aggregator.x_axis_bucket_date_ranges
    check_dates(aggregator.last_meter_date, max_days_out_of_date)
    value = aggregator.valid? ? aggregator.bucketed_data['Energy'][0] : nil
    { value: value, start_date: dates[0][0], end_date: dates[0][1] }
  end

  def check_dates(last_meter_date, max_days_out_of_date)
    return if max_days_out_of_date.nil?
    days_out_of_date = Date.today - max_days_out_of_date
    if last_meter_date < days_out_of_date
      raise EnergySparksMeterDataTooOutOfDate, "last reading #{last_meter_date} = #{days_out_of_date} days out of date"
    end
  end

  # convert { schoolweek: -1..0 } into [ { schoolweek: 0 }, { schoolweek: -1 } ] or [ timescale ]
  # deals with case school week range covers a holiday, so just the school weeks are calculated
  # not the span of weeks including the holiday
  def non_contiguous_timescale_breakdown(timescale)
    return [timescale] unless timescale.is_a?(Hash)
    if timescale.key?(:schoolweek) && timescale[:schoolweek].is_a?(Range)
      timescale[:schoolweek].map{ |swn| {schoolweek: swn} }
    else
      [timescale]
    end
  end

  def generic_aggregation_calculation(time_scale, fuel_type, data_type, override = nil)
    config = {
      name:             'Scalar aggregation request',
      meter_definition: meter_type_from_fuel_type(fuel_type),
      x_axis:           :nodatebuckets,
      series_breakdown: :none,
      yaxis_units:      data_type,
      yaxis_scaling:    :none,
      timescale:        time_scale,

      chart1_type:      :column,
      chart1_subtype:   :stacked
    }

    config.merge!(override) unless override.nil?

    aggregator = Aggregator.new(@meter_collection, config)

    aggregator.aggregate

    aggregator
  end

  def check_data_available_for_fuel_type(fuel_type)
    case fuel_type
    when :gas
      raise EnergySparksNoMeterDataAvailableForFuelType.new('No gas meter data available') unless @meter_collection.gas?
    when :electricity, :allelectricity_unmodified
      raise EnergySparksNoMeterDataAvailableForFuelType.new('No electricity meter data available') unless @meter_collection.electricity?
    when :storage_heaters, :storage_heater
      raise EnergySparksNoMeterDataAvailableForFuelType.new('No storage heater meter data available') unless @meter_collection.storage_heaters?
    when :solar_pv
      raise EnergySparksNoMeterDataAvailableForFuelType.new('No solar pv meter data available') unless @meter_collection.solar_pv_panels?
      :solar_pv_meter
    else
      raise EnergySparksNoMeterDataAvailableForFuelType.new('Unexpected nil fuel type for scalar energy calculation') if fuel_type.nil?
      raise EnergySparksNoMeterDataAvailableForFuelType.new("Unexpected fuel type #{fuel_type} for scalar energy calculation")
    end
  end

  def meter_type_from_fuel_type(fuel_type)
    case fuel_type
    when :gas
      :allheat
    when :electricity
      :allelectricity
    when :allelectricity_unmodified
      :allelectricity_unmodified
    when :storage_heaters, :storage_heater
      :storage_heater_meter
    when :solar_pv
      :solar_pv_meter
    else
      raise EnergySparksBadChartSpecification.new('Unexpected nil fuel type for scalar energy calculation') if fuel_type.nil?
      raise EnergySparksBadChartSpecification.new("Unexpected fuel type #{fuel_type} for scalar energy calculation")
    end
  end
end

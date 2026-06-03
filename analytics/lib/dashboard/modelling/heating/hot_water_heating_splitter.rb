class HotWaterHeatingSplitter
  include Logging

  def initialize(school, fault_tolerant_model_dates: false)
    @school = school
    @fault_tolerant_model_dates = fault_tolerant_model_dates
  end

  def split_heat_and_hot_water(start_date, end_date, meter: @school.aggregated_heat_meters)
    average_hot_water_only_day_kwh_x48 = average_hot_water_day_x48(start_date, end_date, meter: meter)
    average_hot_water_only_day_kwh = average_hot_water_only_day_kwh_x48.sum
    heating_day_dates = []

    heating_days  = AMRData.create_empty_dataset(:heating,    start_date, end_date)
    hotwater_days = AMRData.create_empty_dataset(:hot_water,  start_date, end_date)

    (start_date..end_date).each do |date|
      if @heating_model.model_type?(date) == :summer_occupied_all_days
        hotwater_days.add(date, meter.amr_data.days_amr_data(date))
      elsif @heating_model.model_type?(date) != :none
        hw_day = OneDayAMRReading.new(0, date, 'HSIM', nil, DateTime.now, average_hot_water_only_day_kwh_x48)
        hotwater_days.add(date, hw_day)

        days_data_kwh_x48 = meter.amr_data.days_kwh_x48(date)
        heating_days_data_kwh_x48 = remove_hot_water_from_heating_data(date, days_data_kwh_x48, average_hot_water_only_day_kwh_x48)
        heating_day = OneDayAMRReading.new(0, date, 'HSIM', nil, DateTime.now, heating_days_data_kwh_x48)
        heating_days.add(date, heating_day)
        heating_day_dates.push(date)
      end
    end

    total = meter.amr_data.kwh_date_range(start_date, end_date)
    total_heating = heating_days.total
    total_hot_water = hotwater_days.total
    error = total - total_heating - total_hot_water # would expect small error dur to 'max' function in remove_hot_water_from_heating_data
    {
      heating_only_amr:           heating_days,
      hot_water_only_amr:         hotwater_days,
      average_hot_water_day_kwh:  average_hot_water_only_day_kwh_x48.sum,
      error_kwh:                  error,
      error_percent:              error / total,
      heating_day_dates:          heating_day_dates
    }
  end

  def aggregate_heating_hot_water_split(start_date, end_date, meter: @school.aggregated_heat_meters)
    calc = split_heat_and_hot_water(start_date, end_date, meter: meter)
    heating_kwh   = calc[:heating_only_amr].total
    hotwater_kwh  = calc[:hot_water_only_amr].total
    total_kwh = heating_kwh + hotwater_kwh
    {
      heating_kwh:                heating_kwh,
      hotwater_kwh:               hotwater_kwh,
      total_kwh:                  total_kwh,
      heating_percent:            heating_kwh / total_kwh,
      hotwater_percent:           hotwater_kwh / total_kwh,
      average_hot_water_day_kwh:  calc[:average_hot_water_day_kwh],
      error_kwh:                  calc[:error_kwh],
      error_percent:              calc[:error_percent]
    }
  end

  def split_heat_and_hot_water_aggregate(start_date, end_date, meter: @school.aggregated_heat_meters, data_type: :kwh)
    heating_model = calculate_model(start_date, end_date, meter: meter)

    results = { heating_kwh: 0.0, non_heating_kwh: 0.0, heating_degree_days: [] }

    (start_date..end_date).each do |date|
      if heating_model.heating_on?(date)
        results[:heating_kwh] += meter.amr_data.one_day_kwh(date, data_type)
        results[:heating_degree_days].push(@school.temperatures.degree_days(date))
      else
        results[:non_heating_kwh] += meter.amr_data.one_day_kwh(date, data_type)
      end
    end

    results[:heating_days]      = results[:heating_degree_days].length
    results[:warm_heating_days] = results[:heating_degree_days].select { |dd| dd < 0.5 }.length

    results[:average_heating_degree_days] = average_heating_degreedays(results)
    results.delete(:heating_degree_days)

    results
  rescue => e
    logger.info e.message
    logger.info e.backtrace[0]
    unless Object.const_defined?('Rails')
      puts e.message
      puts e.backtrace[0]
    end
    {}
  end

  def degree_day_adjust_heating(date_ranges, meter: @school.aggregated_heat_meters, adjustment_method: :average, data_type: :kwh)
    return {} if date_ranges.empty?

    date_ranges.sort_by!{ |dr| dr.first }

    data = date_ranges.map { |dr| split_heat_and_hot_water_aggregate(dr.first, somerset_final_august_adjustment(meter, dr.last), data_type: data_type) }

    degree_days = data.map { |d| d[:average_heating_degree_days] }

    average_to_degree_days = adjustment_method == :average ? (degree_days.sum / degree_days.length) : degree_days.last

    data.map.with_index do |period_data, index|
      adjusted_heating = period_data[:heating_kwh] * degree_day_adjustment(period_data[:average_heating_degree_days], average_to_degree_days)
      [
        date_ranges[index],
        adjusted_heating + period_data[:non_heating_kwh]
      ]
    end.to_h
  end

  private

  # to increase the school's being analysed allow some schools
  # to produce results for final month even if incomplete data
  def somerset_final_august_adjustment(meter, month_last_date)
    [meter.amr_data.end_date, month_last_date].min
  end

  def average_heating_degreedays(results)
    return 0.0 if results[:heating_degree_days].nil? || results[:heating_degree_days].empty?
    results[:heating_degree_days].sum / results[:heating_degree_days].length
  end

  def degree_day_adjustment(average_degree_days, average_to_degree_days)
    return 1.0 if average_to_degree_days == 0.0
    average_degree_days / average_to_degree_days
  end

  # TODO(PH, 18Jun2020) probably needs a rethink as result is noisy so sum of inputs != output
  def remove_hot_water_from_heating_data(date_for_debug, heating_and_hw_data_kwh_x48, hot_water_kwh_x48)
    return AMRData.one_day_zero_kwh_x48 if hot_water_kwh_x48.sum > heating_and_hw_data_kwh_x48.sum

    excess_hw_consumption_kwh = 0.0 # rollover any hot water consumption > total consumption to next half hour
    heating_and_hw_data_kwh_x48.each_with_index.map do |hh_kwh, half_hour_index|
      heating_consumption = hh_kwh - hot_water_kwh_x48[half_hour_index] - excess_hw_consumption_kwh
      if heating_consumption < 0.0
        excess_hw_consumption_kwh = -heating_consumption
        heating_consumption = 0.0
      else
        excess_hw_consumption_kwh = 0.0
      end
      heating_consumption
    end
  end

  def average_hot_water_day_x48(start_date, end_date, meter: @school.aggregated_heat_meters)
    @heating_model ||= calculate_model(start_date, end_date, meter: meter)

    hot_water_days = 0
    aggregated_hot_water_days = AMRData.one_day_zero_kwh_x48

    (start_date..end_date).each do |date|
      if @heating_model.model_type?(date) == :summer_occupied_all_days
        days_kwh_x48 = meter.amr_data.days_kwh_x48(date)
        aggregated_hot_water_days = AMRData.fast_add_x48_x_x48(days_kwh_x48, aggregated_hot_water_days)
        hot_water_days += 1
      end
    end

    if hot_water_days.zero?
      AMRData.one_day_zero_kwh_x48
    else
      AMRData.fast_multiply_x48_x_scalar(aggregated_hot_water_days, 1.0 / hot_water_days)
    end
  end

  def calculate_model(start_date, end_date, meter: @school.aggregated_heat_meters)
    days = end_date - start_date + 1
    if @fault_tolerant_model_dates && days < 180
      # monthly analysis code only asks for 1 months data at a time
      # not enough for modelling, so extend to surrounding year
      # potentially computationally expensive as recalculating model for each month
      extend_days_either_side = ((365 - days) / 2.0).to_i
      start_date = [start_date - extend_days_either_side, meter.amr_data.start_date].max
      end_date   = [start_date + 365, meter.amr_data.end_date].min
      start_date = [end_date - 365, meter.amr_data.start_date].max
    end

    model_period = SchoolDatePeriod.new(:heat_balance_simulation, 'Current Year', start_date, end_date)
    meter.heating_model(model_period)
  end
end

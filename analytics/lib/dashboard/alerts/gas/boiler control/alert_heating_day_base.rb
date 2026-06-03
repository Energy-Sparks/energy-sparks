class AlertHeatingDaysBase < AlertGasModelBase
  FROST_PROTECTION_TEMPERATURE = 4

  def heating_day_breakdown_current_year(asof_date)
    @breakdown = @heating_model.heating_day_breakdown(asof_date_minus_one_year(asof_date), asof_date) if @breakdown.nil?
    @breakdown
  end

  def enough_data
    days_amr_data >= 364 ? :enough : :not_enough
  end

  protected def calculate_heating_off_statistics(asof_date, datatype, frost_protection_temperature: FROST_PROTECTION_TEMPERATURE)
    kwh_needed_for_frost_protection = 0.0
    kwh_consumed = 0.0
    start_date = meter_date_one_year_before(aggregate_meter, asof_date)
    (start_date..asof_date).each do |date|
      if !occupied?(date) && @heating_model.heating_on?(date)
        days_kwh_below_frost, days_kwh = days_total_kwh_below_frost(date, frost_protection_temperature, datatype)
        kwh_needed_for_frost_protection += days_kwh_below_frost
        kwh_consumed += days_kwh
      end
    end
    [kwh_needed_for_frost_protection, kwh_consumed]
  end

  private def days_total_kwh_below_frost(date, frost_protection_temperature, datatype)
    days_kwh_x48 = aggregate_meter.amr_data.days_kwh_x48(date, datatype)
    days_temperatures = @school.temperatures.one_days_data_x48(date)
    # create vector of 1s (frosty) and zeros (warm) x 48 for multiplication by kWhx48
    halfhours_of_frost = days_temperatures.map { |temperature| temperature < frost_protection_temperature ? 1.0 : 0.0 }
    kwh_below_frost_level = AMRData.fast_multiply_x48_x_x48(days_kwh_x48, halfhours_of_frost)
    [kwh_below_frost_level.sum, days_kwh_x48.sum, days_temperatures.sum > 0.0]
  end

  # sums the warmest days, where the school has its heating on
  # over and above the target setting (typically average or exemplar)
  protected def calculate_heating_on_statistics(asof_date, modelled_days, number_of_days_target)
    temperature_to_kwh_map = Hash.new(0.0)
    total_kwh_consumed = 0.0
    saving_kwh = 0.0
    start_date = meter_date_one_year_before(aggregate_meter, asof_date)
    (start_date..asof_date).each do |date|
      if @heating_model.heating_on?(date)
        one_day_kwh = aggregate_meter.amr_data.one_day_kwh(date)
        avg_temperature = @school.temperatures.average_temperature(date)
        unique_temp_adjust = 0.00000000001 * Random.rand(100) # make temp index reasonably unique
        temperature_to_kwh_map[avg_temperature + unique_temp_adjust] += one_day_kwh
        total_kwh_consumed += one_day_kwh
      end
    end

    if modelled_days > number_of_days_target # i.e. the school is worse than the target
      num_lowest_days_to_match_target = modelled_days - number_of_days_target
      saving_kwh = total_kwh_for_warmest_n_days(temperature_to_kwh_map, num_lowest_days_to_match_target)
    else
      saving_kwh = 0.0
    end

    [saving_kwh, total_kwh_consumed]
  end

  private def total_kwh_for_warmest_n_days(temperature_to_kwh_map, num_lowest_days_to_match_target)
    sorted_temperatures = temperature_to_kwh_map.sort.to_h
    first_warmest_index = [sorted_temperatures.length - num_lowest_days_to_match_target, 0].max
    sorted_temperatures.values[first_warmest_index...sorted_temperatures.length].sum
  end
end
class TargetMeterTemperatureCompensatedDailyDayTypeStretchTarget < TargetMeterTemperatureCompensatedDailyDayTypeBase

  private

  # stretch target: assume school will turn off heating and hot water
  #                 at weekends and holidays in future
  def should_heating_be_on?(synthetic_date, target_date, target_temperature, _synthetic_amr_data)
    holidays.day_type(target_date) == :schoolday &&
    target_temperature < RECOMMENDED_HEATING_ON_TEMPERATURE
  end
end

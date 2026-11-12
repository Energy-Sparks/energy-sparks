#===================================================================================================
# Jan-August 2022-2023 comparison
module AlertJanAug20222023ComparisonMixIn
  def basic_configuration
    {
      name:                   'Jan-August 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       242,
      current_period:         Date.new(2023, 1, 1)..Date.new(2023, 8, 31),
      previous_period:        Date.new(2022, 1, 1)..Date.new(2022, 8, 31)
    }
  end

  #Override to disable the default period normalisation and temperature compensation
  #applied to the previous period. Instead just return the consumption values
  #for the period, unchanged
  def normalised_period_data(_current_period, previous_period)
    meter_values_period(previous_period)
  end

  #Disable pupil and floor area adjustments between periods
  def pupil_floor_area_adjustment
    1.0
  end
end

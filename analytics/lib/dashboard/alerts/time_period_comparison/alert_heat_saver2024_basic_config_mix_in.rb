#===================================================================================================
# Feb/March 2024 competition
module AlertHeatSaver2024BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Winter Heat Saver Feb-March 2024',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2024, 2, 25)..Date.new(2024, 3, 23),
      previous_period:        Date.new(2023, 2, 26)..Date.new(2023, 3, 25),
    }
  end
end

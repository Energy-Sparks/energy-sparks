#===================================================================================================
# Power up layer down day November 2022
module AlertLayerUpPowerdown11November2022BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Layer up power down day 11 November 2022',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 11, 11)..Date.new(2022, 11, 11),
      previous_period:        Date.new(2021, 11, 12)..Date.new(2021, 11, 12)
    }
  end
end

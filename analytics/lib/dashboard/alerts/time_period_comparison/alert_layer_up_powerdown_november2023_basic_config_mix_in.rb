#===================================================================================================
# Power up layer down day November 2023
module AlertLayerUpPowerdownNovember2023BasicConfigMixIn
  def basic_configuration
    {
      name:                   'Layer up power down day 24 November 2023',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
      previous_period:        Date.new(2023, 11, 17)..Date.new(2023, 11, 17)
    }
  end
end

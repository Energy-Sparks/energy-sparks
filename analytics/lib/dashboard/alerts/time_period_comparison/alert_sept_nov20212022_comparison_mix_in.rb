#===================================================================================================
# September-November 2021-2022 comparison
module AlertSeptNov20212022ComparisonMixIn
  def basic_configuration
    {
      name:                   'Autumn term 2021 versus 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 9, 1)..Date.new(2022, 11, 30),
      previous_period:        Date.new(2021, 9, 1)..Date.new(2021, 11, 30)
    }
  end
end

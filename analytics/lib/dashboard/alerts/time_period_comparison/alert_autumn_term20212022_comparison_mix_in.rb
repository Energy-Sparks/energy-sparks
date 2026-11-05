#===================================================================================================
# Autumn term 2021-2022 comparison
module AlertAutumnTerm20212022ComparisonMixIn
  def basic_configuration
    {
      name:                   'Autumn term 2021 versus 2022 energy use comparison',
      max_days_out_of_date:   365,
      enough_days_data:       1,
      current_period:         Date.new(2022, 9, 5)..Date.new(2022, 12, 16),
      previous_period:        Date.new(2021, 9, 6)..Date.new(2021, 12, 17)
    }
  end
end

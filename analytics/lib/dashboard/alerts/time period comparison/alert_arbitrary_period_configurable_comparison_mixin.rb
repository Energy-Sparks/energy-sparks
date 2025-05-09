# frozen_string_literal: true

module AlertArbitraryPeriodConfigurableComparisonMixIn
  include ArbitraryPeriodComparisonMixIn

  # configuration example
  # {
  #   name: 'Layer up power down day 24 November 2023',
  #   max_days_out_of_date: 365,
  #   enough_days_data: 1,
  #   current_period: Date.new(2023, 11, 24)..Date.new(2023, 11, 24),
  #   previous_period: Date.new(2023, 11, 17)..Date.new(2023, 11, 17)
  # }
  attr_accessor :comparison_configuration
end

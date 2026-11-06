require_relative 'heating_non_heating_regression_model_base'

module AnalyseHeatingAndHotWater
  # regression model, but single separation kWh/day value read at fixed temperature
  class HeatingNonHeatingRegressionFixedTemperatureDisaggregationModel < HeatingNonHeatingRegressionModelBase
    AVERAGE_TEMPERATURE_FOR_REGRESSION = 18.0
    def self.type; :fixed_single_value_temperature_sensitive_regression_model end

    def average_max_non_heating_day_kwh
      model_prediction(AVERAGE_TEMPERATURE_FOR_REGRESSION)
    end

    private

    def t_description
      "(T = #{REPRESENTATIVE_SUMMER_TEMPERATURE})"
    end

    def calculate_from_regression(_date)
      model_prediction(REPRESENTATIVE_SUMMER_TEMPERATURE)
    end
  end
end

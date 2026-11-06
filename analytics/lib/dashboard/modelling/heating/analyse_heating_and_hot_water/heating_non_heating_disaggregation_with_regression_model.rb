require_relative 'heating_non_heating_regression_fixed_temperature_disaggregation_model'

module AnalyseHeatingAndHotWater
  # basic regression model
  class HeatingNonHeatingDisaggregationWithRegressionModel < HeatingNonHeatingRegressionFixedTemperatureDisaggregationModel
    def self.type; :temperature_sensitive_regression_model end

    def calculate_from_regression(date)
      avg_temp = temperatures.average_temperature(date)
      [model_prediction(avg_temp), 0.0].max
    end

    def t_description
      'T'
    end
  end
end

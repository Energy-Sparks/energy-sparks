require_relative 'regression_model_temperature'

module AnalyseHeatingAndHotWater
  class HeatingModel
    class RegressionModelTemperatureManuallyConfigured < RegressionModelTemperature
      attr_accessor :x, :y # override attr_reader

      def initialize(key, long_name, a, b, base_temperature)
        super(key, long_name, a, b, 0.0, nil, nil, nil)
        @base_temperature = base_temperature
      end
    end
  end
end

# older heating regression models temperarily deprecated
require_relative 'regression_model_temperature'

module AnalyseHeatingAndHotWater
  class HeatingModel
    class RegressionModel < RegressionModelTemperature
      attr_reader :base_temperature

      def initialize(key, long_name, a, b, r2, base_temp, samples, x, y)
        super(key, long_name, a, b, r2, samples, x, y)
        @base_temperature = base_temp
      end

      def predicted_kwh_temperature(temperature)
        ddays = [@base_temperature - temperature, 0].max
        predicted_kwh_degreedays(ddays)
      end

      def to_s
        a.nan? ? 'kwh=NaN' : sprintf('kwh=%.0f+%.0dxDD@Tb%.1fC,R2=%.2f,N=%d', a, b, base_temperature, r2, samples)
      end

      def format_sorted_raw_data
        sort_raw_data.map { |p| "T:#{(@base_temperature-p[0]).round(1)}kWh:#{p[1].round(0)}" }.join(', ')
      end

      def predicted_kwh_degreedays(degreedays)
        @a + @b * degreedays
      end

      def degreedays(temperature)
        temperature > @base_temperature ? 0.0 : @base_temperature - temperature
      end
    end
  end
end

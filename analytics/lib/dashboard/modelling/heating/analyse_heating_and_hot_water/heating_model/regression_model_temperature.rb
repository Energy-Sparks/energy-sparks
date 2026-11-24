require_relative '../heating_model'

module AnalyseHeatingAndHotWater
  class HeatingModel
    # nested class: this is the basic model for holding the linear regression parameters
    class RegressionModelTemperature
      include Logging

      attr_reader :key, :long_name, :a, :b, :r2, :standard_error, :x_data, :y_data
      attr_accessor :base_temperature
      attr_writer :samples # only want to set, as nil tolerant getter but want to set in derived class

      def initialize(key, long_name, a, b, r2, samples, x, y)
        @key = key
        @long_name = long_name
        @a = a
        @b = b
        @r2 = r2
        @samples = samples
        @x_data = x
        @y_data = y
        @base_temperature = nil
      end

      def thermally_massive?
        false
      end

      def predicted_kwh_temperature(temperature)
        base_temp_problem_or_not_set = @base_temperature.nil? || @base_temperature.nan?
        @a + (@b * (base_temp_problem_or_not_set ? temperature : [temperature, @base_temperature].min))
      end

      def valid?
        !@a.nil? && !@b.nil? && !@samples.nil?
      end

      def samples
        @samples.nil? ? 0 : @samples
      end

      def differences_from_model
        @x_data.map.with_index { |_x, i| y_data[i] - (a + (b * x_data[i])) }
      end

      def standard_deviation_from_model
        @x_data.nil? ? Float::NAN : EnergySparks::Maths.standard_deviation(differences_from_model)
      end

      def to_s
        # logger.info "a #{a} b #{b} r2 #{r2} x #{samples} bt #{base_temp_display}"
        a.nan? ? 'kwh=NaN' : format('kwh=%.0f+%.0fxT,R2=%.2f,N=%d baseT=%sC', a, b, r2, samples, base_temp_display)
      end

      # for debugging, display
      def configuration
        {
          a: [a,                 :kwh],
          b: [b,                 :kwh, :temperature],
          r2: [r2, :float_2dp],
          samples: [samples, :integer],
          base_temperature: [base_temperature, :temperature]
        }
      end

      def base_temp_display
        @base_temperature.nil? ? '' : format('%.1f', @base_temperature)
      end

      # sorted array of [DD, kWh] pairs
      def sort_raw_data
        @x_data.zip(y_data).sort_by { |a| a[0] }
      end

      def format_sorted_raw_data
        sort_raw_data.map { |p| "T:#{p[0].round(1)}kWh:#{p[1].round(0)}" }.join(', ')
      end
    end
  end
end

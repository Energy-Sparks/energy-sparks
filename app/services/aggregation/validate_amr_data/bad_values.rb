# frozen_string_literal: true

module Aggregation
  class ValidateAmrData
    module BadValues
      def self.upper_lower(string)
        epsilon = 1.0 * (10**-string.split('.').last.size)
        float = string.delete(',').to_f
        [float - epsilon, float + epsilon]
      end

      # https://support.n3rgy.com/support/solutions/articles/103000130415-erroneous-consumption-value-4294967-295-kwh-electricity-
      ELECTRICITY = %w[4,294,967.295 2,147,483.647 8,590.017 8,590.041 34,364.271 4,295.103 4,295.084
                       8,590.119 8,590.063 8,591.484 8,590.421 38,655.37 186,227.0865].map { |s| upper_lower(s) }
      # https://support.n3rgy.com/support/solutions/articles/103000130398-erroneous-consumption-value-16777-215-gas-
      GAS = %w[16,777.215 8,590.017 8,590.041 34,364.271 4,295.103 4,295.084 8,590.119 8,590.063 8,591.484 8,590.421
               38,655.37 186,227.0865].map { |s| upper_lower(s) }

      def self.bad_dcc_value?(kwh, meter_type)
        (meter_type == :electricity && ELECTRICITY.any? { |lower, upper| kwh.between?(lower, upper) }) ||
          (meter_type == :gas && GAS.any? { |lower, upper| kwh.between?(lower, upper) })
      end
    end
  end
end

require_relative '../model_cache'

module AnalyseHeatingAndHotWater
  class ModelCache
    class HeatingModelOverrides
      attr_reader :override_best_model_type, :override_regression_model, :reason, :function, :fitting,
                  :heating_non_heating_day_separation_model_override, :heating_non_heating_day_fixed_kwh_separation

      def initialize(meter, ignore_meter_attributes = false)
        @meter = meter
        overrides = meter.attributes(:heating_model)
        if overrides.nil? || ignore_meter_attributes
          @override_best_model_type = nil
          @override_regression_model = nil
          @reason = nil
          @fitting = nil
        else
          @override_best_model_type = overrides.fetch(:override_best_model_type, nil)
          @override_regression_model = overrides.fetch(:override_model, nil)
          @reason = overrides.fetch(:reason, nil)
          @fitting = overrides.fetch(:fitting, nil)
        end

        @heating_non_heating_day_fixed_kwh_separation = meter.attributes(:heating_non_heating_day_fixed_kwh_separation)
        @heating_non_heating_day_separation_model_override = meter.attributes(:heating_non_heating_day_separation_model_override)

        @function = meter.attributes(:function)
      end

      def self.no_overrides(meter)
        HeatingModelOverrides.new(meter, true)
      end
    end
  end
end

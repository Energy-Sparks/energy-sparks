require_relative 'heating_non_heating_disaggregation_model_base'

module AnalyseHeatingAndHotWater
  # fixed kWh/day override from meter attributes - either a value or 0.0/infinity if heating/non-heating only
  class HeatingNonHeatingFixedValueOverrideDisaggregationModel < HeatingNonHeatingDisaggregationModelBase
    def self.type; :fixed_single_value_kwh_per_day_override end
    def initialize(heat_meter, model_overrides)
      @fix_kwh_per_day = calculate_fixed_kwh_per_day(heat_meter, model_overrides)
    end

    def calculate_max_summer_hotwater_kitchen_kwh(_period)
      Logging.logger.info "HW separation kWh for fixed model is #{@fix_kwh_per_day}"
      # do nothing
    end

    def max_non_heating_day_kwh(_date)
      @fix_kwh_per_day
    end

    def average_max_non_heating_day_kwh
      @fix_kwh_per_day
    end

    private

    def calculate_fixed_kwh_per_day(heat_meter, model_overrides)
      if model_overrides.heating_non_heating_day_fixed_kwh_separation
        model_overrides.heating_non_heating_day_fixed_kwh_separation
      elsif heat_meter.heating_only?
        # heating_only assume 0.0
        0.0
      elsif heat_meter.non_heating_only?
        123456789.0 # set really high number so all assumed as non heating use
      end
    end
  end
end

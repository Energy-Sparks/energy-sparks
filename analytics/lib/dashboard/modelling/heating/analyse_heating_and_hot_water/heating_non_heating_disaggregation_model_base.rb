require_relative 'heating_model_temperature_space'

module AnalyseHeatingAndHotWater
  # regression models associated with hot water, and
  # particularly identifying heating versus non-heating days
  # series of models where the default can be overridden by meter attributes
  # if the automatically modelling gets the separation between heating
  # and (summer) non-heating days doesn't work
  # the models sample data in mid-summer and assume +/- a bit that
  # mid summer data is representative of the heating being off
  # sometimes it gets it wrong because the heating is left on all summer
  # or for example the hot water system is inefficient and temperature
  # sensitive because of a lack of insulation, and to some extent its
  # inefficiency/heat loss becomes ambient heating even when not wanted in the summer!
  class HeatingNonHeatingDisaggregationModelBase < HeatingModelTemperatureSpace
    include Logging
    attr_reader :model_results
    def initialize(heat_meter, model_overrides)
      raise EnergySparksAbstractBaseClass, "Abstract base class for heating, non-heating model max disaggregator called"  if self.instance_of?(HeatingNonHeatingDisaggregationModelBase)
      super(heat_meter, model_overrides)
    end

    def self.models
      [
        HeatingNonHeatingRegressionFixedTemperatureDisaggregationModel,
        HeatingNonHeatingDisaggregationWithRegressionModel,
        HeatingNonHeatingDisaggregationWithRegressionCOVIDTolerantModel,
        # plus HeatingNonHeatingFixedValueOverrideDisaggregationModel see method all_models below
      ]
    end

    def self.default_type
      :best
    end

    def self.best_non_override_model
      :temperature_sensitive_regression_model_covid_tolerant
    end

    def self.model_types
      models.map(&:type)
    end

    # either use a specific model, the 'best' model, or one defined by a meter attribute override
    def self.model_factory(type, heat_meter, model_overrides)
      model = model_factory_private(type, heat_meter, model_overrides)
      Logging.logger.info "Using #{model.class.name} for heating/non heating model separation for mprn #{heat_meter.mpan_mprn}"
      model
    end

    def self.override_or_best_model(type, heat_meter, model_overrides)
      if best_type(type)
        override_model = model_overrides.heating_non_heating_day_separation_model_override
        override_model = override_model.nil? ? nil : override_model.to_sym # defensive paranoia
        type =  if fixed_override_model(heat_meter, model_overrides)
                  :fixed_single_value_kwh_per_day_override
                elsif override_model && !%i[no_idea either].include?(override_model)
                  override_model
                else
                  best_non_override_model
                end
      else
        type
      end
    end

    def self.model_type_description(type, heat_meter, model_overrides)
      type = override_or_best_model(type, heat_meter, model_overrides)
      if type == :fixed_single_value_kwh_per_day_override
        type + " (at #{model_overrides.heating_non_heating_day_fixed_kwh_separation} kWh/day)"
      else
        type
      end
    end

    private

    # technically the fixed override model is only a model if overidden
    # its not one of the default models which can be choosen/tested
    def self.all_models
      [models, HeatingNonHeatingFixedValueOverrideDisaggregationModel].flatten
    end

    def self.model_factory_private(type, heat_meter, model_overrides)
      type = override_or_best_model(type, heat_meter, model_overrides)

      all_models.each do |model|
        return model.new(heat_meter, model_overrides) if model.type == type
      end

      raise EnergySparksUnexpectedStateException, "Unknown heat non-heat disaggregation model #{type}"
    end

    def self.fixed_override_model(heat_meter, model_overrides)
      model_overrides.heating_non_heating_day_fixed_kwh_separation ||
      heat_meter.heating_only? ||
      heat_meter.non_heating_only?
    end

    def self.best_type(type)
      # see documentation, but no_idea = 'anyones guess whats best to do'
      # either: either of Covid or non-COVID regression models - equlivalent to 'best'
      type.nil? || %i[best no_idea either].include?(type)
    end
  end
end

require_relative '../analyse_heating_and_hot_water'

module AnalyseHeatingAndHotWater
  # caches the definitions and resultant calculations for a number of models
  # associated with a meter
  class ModelCache
    include Logging

    def initialize(meter)
      @meter = meter
      logger.debug { "Creating model cache for meter #{meter.id}" }
      @processed_model_overrides = false
      @models = {}
    end

    private def override_model_start_end_dates?(allow_more_than_1_year, period)
      return false if @model_overrides.fitting.nil?
      return false if period.end_date >= @model_overrides.fitting[:expiry_date_of_override]
      return false if allow_more_than_1_year && !@model_overrides.fitting[:use_dates_for_model_validation]

      true
    end

    # called from alerts, to avoid picking up precached
    # model from charting which a different asof_date
    # should onlt be required in analystics when
    # testing charting and alerts at the same time
    def clear_model_cache
      @models = {}
    end

    def create_and_fit_model(heating_model_type, period, allow_more_than_1_year = false, non_heating_model_type = nil)
      logger.debug do
        "create_and_fit_model start. type: #{heating_model_type} " \
          "non_model_type: #{non_heating_model_type}; period: #{period.type} #{period.start_date} to #{period.end_date}"
      end
      # use composite key to index model for caching
      model_type = { heat_model: heating_model_type, period: period, years: allow_more_than_1_year,
                     non_heating_model: non_heating_model_type }

      unless @processed_model_overrides # deferred until meter available
        @model_overrides = HeatingModelOverrides.new(@meter)
        @processed_model_overrides = true
      end

      if override_model_start_end_dates?(allow_more_than_1_year, period)
        period = SchoolDatePeriod.new(
          :overridden_model_start_end_dates,
          'Overridden Model Start - End Dates',
          @model_overrides.fitting[:fit_model_start_date],
          @model_overrides.fitting[:fit_model_end_date]
        )
      end

      if @models.key?(model_type)
        logger.debug { 'Returning cached heating model' }
        return @models[model_type]
      end

      case heating_model_type
      when :simple_regression_temperature
        enough_amr_data?
        @models[model_type] = HeatingModelTemperatureSpace.new(@meter, @model_overrides)
        @models[model_type].calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type)
      when :simple_regression_temperature_no_overrides
        enough_amr_data?
        @models[model_type] = HeatingModelTemperatureSpace.new(@meter, HeatingModelOverrides.no_overrides(@meter))
        @models[model_type].calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type)
      when :thermal_mass_regression_temperature
        enough_amr_data?
        @models[model_type] = HeatingModelTemperatureSpaceThermalMass.new(@meter, @model_overrides)
        @models[model_type].calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type)
      when :override_model
        type = @model_overrides.override_regression_model[:type]
        if type == :simple_regression_temperature
          @models[:override_model] = HeatingModelTemperatureSpaceManuallyConfigured.new(@meter, @model_overrides)
        elsif type == :thermal_mass_regression_temperature
          @models[:override_model] =
            HeatingModelThermalMassingModeTemperatureSpaceManuallyConfigured.new(@meter, @model_overrides)
        else
          raise EnergySparksUnexpectedStateException,
                'Unexpected model_type missing or misconfigured override_best_model_type parameter?'
        end
        @models[model_type].calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type)
      when :best
        @models[model_type] = best_model(period, allow_more_than_1_year)
      else
        raise EnergySparksUnexpectedStateException, "Unexpected model_type #{model_type}"
      end
      logger.debug { 'create_and_fit_model end' }

      @models[model_type]
    end

    private def enough_amr_data?
      return true unless @meter.amr_data.days < 30

      raise EnergySparksNotEnoughDataException,
            "Not enough amr data for model to provide good regression fit #{@meter.amr_data.days} days"
    end

    private

    def best_model(period, allow_more_than_1_year)
      simple_model = create_and_fit_model(:simple_regression_temperature, period, allow_more_than_1_year)
      thermal_mass_model = create_and_fit_model(:thermal_mass_regression_temperature, period, allow_more_than_1_year)
      unless @model_overrides.override_regression_model.nil?
        override_model = create_and_fit_model(:override_model, period,
                                              allow_more_than_1_year)
      end

      if @model_overrides.override_regression_model.nil?
        if simple_model.enough_samples_for_good_fit && !thermal_mass_model.enough_samples_for_good_fit
          return simple_model
        end

        unless simple_model.enough_samples_for_good_fit
          raise EnergySparksNotEnoughDataException,
                "Not enough samples for model to provide good regression fit simple: #{simple_model.winter_heating_samples} massive: #{thermal_mass_model.winter_heating_samples} mpan or mprn #{@meter.mpan_mprn} period: #{period.start_date} to #{period.end_date}"
        end

        thermal_mass_model.standard_deviation_percent < simple_model.standard_deviation_percent ? thermal_mass_model : simple_model
      else
        override_model
      end
    end
  end
end

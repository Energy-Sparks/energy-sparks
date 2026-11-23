require_relative 'heating_model_temperature_space'

module AnalyseHeatingAndHotWater
  # heavy thermal mass (day of week) version of temperature space regression model
  class HeatingModelTemperatureSpaceThermalMass < HeatingModelTemperatureSpace
    SCHOOLDAYHEATINGMODELTYPES = %i[heating_occupied_monday heating_occupied_tuesday heating_occupied_wednesday
                                    heating_occupied_thursday heating_occupied_friday].freeze
    HEATINGMODELTYPES = SCHOOLDAYHEATINGMODELTYPES + [HEATINGWEEKENDMODEL, HEATINGHOLIDAYMODEL]
    ALLMODELTYPES = %i[heating_occupied_monday heating_occupied_tuesday heating_occupied_wednesday heating_occupied_thursday heating_occupied_friday
                       weekend_heating holiday_heating
                       summer_occupied_all_days holiday_hotwater_only weekend_hotwater_only none].freeze
    def initialize(heat_meter, model_overrides)
      super
    end

    def name
      'Thermally massive'
    end

    def thermally_massive?
      true
    end

    def heating_model_for_future_date(date)
      if holiday?(date)
        HEATINGHOLIDAYMODEL
      else
        weekend?(date) ? HEATINGWEEKENDMODEL : school_day_model(date)
      end
    end

    def winter_heating_model_types
      SCHOOLDAYHEATINGMODELTYPES
    end

    def average_heating_b_kwh_per_1_C_per_day
      b_total = 0.0
      SCHOOLDAYHEATINGMODELTYPES.each do |model_type|
        b_total += @models[model_type].b
      end
      b_total / SCHOOLDAYHEATINGMODELTYPES.length
    end

    def winter_heating_samples
      if SCHOOLDAYHEATINGMODELTYPES.any? { |model_type| model(model_type).nil? || !model(model_type).valid? }
        logger.warn 'Not all winter heating models are valid, returning 0.0'
        0.0
      else
        SCHOOLDAYHEATINGMODELTYPES.map { |model_type| model(model_type).samples }.sum
      end
    end

    # 60 value needs further research across multiple schools
    def minimum_samples_for_model_to_run_well
      MINIMUM_SAMPLES_FOR_THERMALLY_MASSIVE_MODEL_TO_RUN_WELL
    end

    def all_heating_model_types # derived as constants not inherited
      ALLMODELTYPES
    end

    def school_day_model(date)
      if date.saturday? || date.sunday?
        raise EnergySparksUnexpectedStateException.new("Unexpected weekend date #{date}")
      end

      SCHOOLDAYHEATINGMODELTYPES[date.wday - 1]
    end

    # mathetically not meaningful
    def average_base_temperature
      base_temperatures = SCHOOLDAYHEATINGMODELTYPES.map { |doy| calculate_base_temperature_by_parameter(doy) }
      base_temperatures.inject(:+) / base_temperatures.length
    end

    # mathetically not meaningful
    def average_heating_school_day_a
      SCHOOLDAYHEATINGMODELTYPES.map { |dow| @models[dow].a }.inject(:+) / SCHOOLDAYHEATINGMODELTYPES.length
    end

    # mathetically not meaningful
    def average_heating_school_day_b
      SCHOOLDAYHEATINGMODELTYPES.map { |dow| @models[dow].b }.inject(:+) / SCHOOLDAYHEATINGMODELTYPES.length
    end

    # mathematically not meaningful
    def average_heating_school_day_r2
      if @meter.non_heating_only?
        Float::NAN
      else
        valid_heating_models.map { |doy| @models[doy].r2 }.inject(:+) / SCHOOLDAYHEATINGMODELTYPES.length
      end
    end

    def valid_heating_models
      SCHOOLDAYHEATINGMODELTYPES.select { |doy| !@models[doy].nil? }
    end

    def number_of_heating_school_days
      SCHOOLDAYHEATINGMODELTYPES.map { |doy| @models[doy].samples }.inject(:+)
    end
  end
end

require_relative './heating_regression_models.rb'
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

  # base regression model - not actually called, but derived models are
  # samples summer months, assuming the heating is off and then calculates
  # a regression with a standard deviation spread to seperate heating and non-heating days
  class HeatingNonHeatingRegressionModelBase < HeatingNonHeatingDisaggregationModelBase
    SUMMER_MONTHS = [6, 7, 8]
    REPRESENTATIVE_SUMMER_TEMPERATURE = 20.0

    def max_non_heating_day_kwh(date)
      calculate_from_regression(date)
    end

    def calculate_max_summer_hotwater_kitchen_kwh(period)
      @model_results ||= calculate_max_hotwater_only_daily_kwh(period)
    end

    private

    def model_prediction(avg_temperature)
      model_calculation(@model_results, avg_temperature)
    end

    def model_calculation(calc, temperature)
      calc[:a] + temperature * calc[:b] + 2 * calc[:sd]
    end

    def calculate_max_hotwater_only_daily_kwh(period)
      boiler_days, days, boiler_off_days = boiler_on_days(period, SUMMER_MONTHS)

      # if for more than half the days in the summer the boiler is off
      # assume heating only and set to threshold of gas kWh noise
      if (1.0 * boiler_days.length / days.length) < 0.5
        return synthesize_heating_only_model_calculation(boiler_days, boiler_off_days)
      end

      calc, sd = regress_boiler_on_days(boiler_days)

      results = {
        a:            calc.a,
        b:            calc.b,
        r2:           calc.r2,
        non_heat_n:   boiler_days.length,
        heat_n:       boiler_off_days.length,
        calculation:  "a #{calc.a.round(1)} + b #{calc.b.round(2)} * #{t_description} r2 #{calc.r2.round(2)} sd #{sd.round(2)} on: #{boiler_days.length} off: #{boiler_off_days.length}",
        sd:           sd,
        model:        self.class.type
      }

      results[:split_at_18c] = model_calculation(results, 18.0)

      if valid_results?(results)
        Logging.logger.info "HW separation regression model:"
        format_calculation_results(results).each do |row|
          Logging.logger.info row
        end
        results
      else
        log_data(results, boiler_days, "NaN regression results from heat/non-heat separation")
        logger.info 'This is really an error by provides synthetic model for fault tolerance'
        synthesize_heating_only_model_calculation(boiler_days, boiler_off_days)
      end
    end

    def format_calculation_results(results)
      results.map do |field, value|
        "    #{sprintf('%-15.15s', field)} #{value}"
      end
    end

    def valid_results?(results)
      %i[a b r2 sd].all? { |s| !results[s].nan? }
    end

    def log_data(results, days, message)
      logger.info { message }
      logger.info { "kwh: #{days.map { |date| @amr_data.one_day_kwh(date) }.join(', ')}" }
      logger.info { "temps: #{days.map { |date| temperatures.average_temperature(date) }.join(', ')}" }
    end

    # no summer usage so synthesize a model
    def synthesize_heating_only_model_calculation(boiler_days, boiler_off_days)
      {
        a:            @max_zero_daily_kwh,
        b:            0.0,
        r2:           1.0,
        non_heat_n:   boiler_days.length,
        heat_n:       boiler_off_days.length,
        calculation:  "heating only: a #{@max_zero_daily_kwh.round(1)} on: #{boiler_days.length} off: #{boiler_off_days.length}",
        sd:           0.0,
        model:        self.class.type
      }
    end

    def boiler_on_days(period, list_of_months)
      days = occupied_school_days(period, list_of_months)
      boiler_days     = days.select { |date| boiler_on?(date) }
      boiler_off_days = days.select { |date| boiler_off?(date) }
      [boiler_days, days, boiler_off_days]
    end

    def occupied_school_days(period, list_of_months)
      (period.start_date..period.end_date).map do |date|
        occupied?(date) && list_of_months.include?(date.month) ? date : nil
      end.compact
    end

    def regress_boiler_on_days(days)
      kwhs      = days.map { |date| @amr_data.one_day_kwh(date) }
      avg_temps = days.map { |date| temperatures.average_temperature(date) }
      sd = EnergySparks::Maths.standard_deviation(kwhs)
      [regression(:summer_occupied_all_days, avg_temps, kwhs), sd]
    end
  end

  # regression model, but single separation kWh/day value read at fixed temperature
  class HeatingNonHeatingRegressionFixedTemperatureDisaggregationModel < HeatingNonHeatingRegressionModelBase
    AVERAGE_TEMPERATURE_FOR_REGRESSION = 18.0
    def self.type; :fixed_single_value_temperature_sensitive_regression_model end

    def average_max_non_heating_day_kwh
      model_prediction(AVERAGE_TEMPERATURE_FOR_REGRESSION)
    end

    private

    def t_description
      "(T = #{REPRESENTATIVE_SUMMER_TEMPERATURE})"
    end

    def calculate_from_regression(_date)
      model_prediction(REPRESENTATIVE_SUMMER_TEMPERATURE)
    end
  end

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

  # as per the basic regression model but gets its summer data from 2019
  # to avoid 2020 COVID period when summer usage was 'strange' at some schools
  class HeatingNonHeatingDisaggregationWithRegressionCOVIDTolerantModel < HeatingNonHeatingDisaggregationWithRegressionModel
    def self.type; :temperature_sensitive_regression_model_covid_tolerant end

    private

    def occupied_school_days(period, list_of_months)
      school_days = super(period, list_of_months)
      if meter_data_available_in_2019?(list_of_months) && all_in_covid_lock_down(school_days)
        school_days = occupied_school_days_2019(list_of_months)
      end
      school_days
    end

    def all_in_covid_lock_down(days)
      days.all? { |date| DateTimeHelper.covid_lockdown_date?(date) }
    end

    def meter_data_available_in_2019?(list_of_months)
      @meter.amr_data.start_date <= first_day_of_months(list_of_months) &&
      @meter.amr_data.end_date   >= last_day_of_months(list_of_months)
    end

    def occupied_school_days_2019(list_of_months)
      (first_day_of_months(list_of_months)..last_day_of_months(list_of_months)).map do |date|
        occupied?(date) && list_of_months.include?(date.month) ? date : nil
      end.compact
    end

    def first_day_of_months(list_of_months)
      Date.new(2019, list_of_months.min, 1)
    end

    def last_day_of_months(list_of_months)
      DateTimeHelper.last_day_of_month(Date.new(2019, list_of_months.max, 1))
    end
  end
end

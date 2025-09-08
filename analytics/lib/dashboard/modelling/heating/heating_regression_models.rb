# Analyse heating, hot water and kitchen
# FYI: some abiguity in use of terms may confuse:
#   summer - equivalent to - non_heating, kitchen_only, hotwater_only
#   winter - equivalent to - heating
#
module AnalyseHeatingAndHotWater
  # both these constants are 'publicly' documented on the model fitting advice web pages
  MINIMUM_NON_HEATING_MODEL_SAMPLES = 15
  MINIMUM_SAMPLES_FOR_SIMPLE_MODEL_TO_RUN_WELL = 35
  MINIMUM_SAMPLES_FOR_THERMALLY_MASSIVE_MODEL_TO_RUN_WELL = 60
  # caches the definitions and resultant calculations for a number of models
  # associated with a meter
  class ModelCache
    include Logging
    def initialize(meter)
      @meter = meter
      logger.info "Creating model cache for meter #{meter.id}"
      @processed_model_overrides = false
      @models = {}
    end

    def results(model_type)
      @models[model_type]
    end

    def holidays
      @meter.meter_collection.holidays
    end

    def temperatures
      @meter.meter_collection.temperatures
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
      logger.info "create_and_fit_model start heat #{heating_model_type} hw #{non_heating_model_type} #{period.start_date} to #{period.end_date}"
      # use composite key to index model for caching
      model_type = { heat_model: heating_model_type, period: period, years: allow_more_than_1_year, non_heating_model: non_heating_model_type}

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

      return @models[model_type] if @models.key?(model_type)

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
          @models[:override_model] = HeatingModelThermalMassingModeTemperatureSpaceManuallyConfigured.new(@meter, @model_overrides)
        else
          raise EnergySparksUnexpectedStateException.new('Unexpected model_type missing or misconfigured override_best_model_type parameter?')
        end
        @models[model_type].calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type)
      when :best
        @models[model_type] = best_model(period, allow_more_than_1_year)
      else
        raise EnergySparksUnexpectedStateException.new("Unexpected model_type #{model_type}")
      end
      logger.info "create_and_fit_model end"

      @models[model_type]
    end

    private def enough_amr_data?
      if @meter.amr_data.days < 30
        raise EnergySparksNotEnoughDataException, "Not enough amr data for model to provide good regression fit #{@meter.amr_data.days} days"
      end
    end

    class HeatingModelOverrides
      attr_reader :override_best_model_type
      attr_reader :override_regression_model, :reason, :function, :fitting
      attr_reader :heating_non_heating_day_separation_model_override
      attr_reader :heating_non_heating_day_fixed_kwh_separation

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

        @heating_non_heating_day_fixed_kwh_separation  = meter.attributes(:heating_non_heating_day_fixed_kwh_separation)
        @heating_non_heating_day_separation_model_override  = meter.attributes(:heating_non_heating_day_separation_model_override)

        @function = meter.attributes(:function)
      end

      def self.no_overrides(meter)
        HeatingModelOverrides.new(meter, true)
      end
    end

    private

    def best_model(period, allow_more_than_1_year)
      simple_model = create_and_fit_model(:simple_regression_temperature, period, allow_more_than_1_year)
      thermal_mass_model = create_and_fit_model(:thermal_mass_regression_temperature, period, allow_more_than_1_year)
      override_model = create_and_fit_model(:override_model, period, allow_more_than_1_year) unless @model_overrides.override_regression_model.nil?

      if !@model_overrides.override_regression_model.nil?
        override_model
      else
        return simple_model if simple_model.enough_samples_for_good_fit && !thermal_mass_model.enough_samples_for_good_fit

        if !simple_model.enough_samples_for_good_fit
          raise EnergySparksNotEnoughDataException, "Not enough samples for model to provide good regression fit simple: #{simple_model.winter_heating_samples} massive: #{thermal_mass_model.winter_heating_samples} mpan or mprn #{@meter.mpan_mprn} period: #{period.start_date} to #{period.end_date}"
        end
        thermal_mass_model.standard_deviation_percent < simple_model.standard_deviation_percent ? thermal_mass_model : simple_model
      end
    end
  end

  #====================================================================================================================
  # HEATING MODEL REGRESSION ANALYSIS
  #
  # regression modelling for heating (and non-heating) of school
  # minimum granularity one day
  # splits daily heating consumption into heating and non heating days
  # and between school days, holidays and weekends
  # basic model: predicted days kwh = A + B * outside temperature
  # thermally massive variant, splits up school week: Monday thru Friday
  class HeatingModel
    include Logging

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
        @a + @b * (base_temp_problem_or_not_set ? temperature : [temperature, @base_temperature].min)
      end

      def valid?
        !@a.nil? && !@b.nil? && !@samples.nil?
      end

      def samples
        @samples.nil? ? 0 : @samples
      end

      def differences_from_model
        @x_data.map.with_index{ |_x, i| y_data[i] - (a + b * x_data[i]) }
      end

      def standard_deviation_from_model
        @x_data.nil? ? Float::NAN : EnergySparks::Maths.standard_deviation(differences_from_model)
      end

      def to_s
        # logger.info "a #{a} b #{b} r2 #{r2} x #{samples} bt #{base_temp_display}"
        a.nan? ? 'kwh=NaN' : sprintf('kwh=%.0f+%.0fxT,R2=%.2f,N=%d baseT=%sC', a, b, r2, samples, base_temp_display)
      end

      # for debugging, display
      def configuration
        {
          a:                [a,                 :kwh],
          b:                [b,                 :kwh, :temperature],
          r2:               [r2,                :float_2dp],
          samples:          [samples,           :integer],
          base_temperature: [base_temperature,  :temperature]
        }
      end

      def base_temp_display
        @base_temperature.nil? ? '' : sprintf('%.1f', @base_temperature)
      end

      # sorted array of [DD, kWh] pairs
      def sort_raw_data
        @x_data.zip(y_data).sort { |a,b| a[0] <=> b[0] }
      end

      def format_sorted_raw_data
        sort_raw_data.map { |p| "T:#{p[0].round(1)}kWh:#{p[1].round(0)}" }.join(', ')
      end
    end

    class RegressionModelTemperatureManuallyConfigured < RegressionModelTemperature
      attr_accessor :x, :y # override attr_reader
      def initialize(key, long_name, a, b, base_temperature)
        super(key, long_name, a, b, 0.0, nil, nil, nil)
        @base_temperature = base_temperature
      end
    end

    attr_reader :models, :heating_on_periods, :heating_days_of_week_parameters
    attr_reader :model_config
    attr_accessor :base_degreedays_temperature

    def initialize(meter, model_overrides)
      @amr_data = meter.amr_data
      @meter = meter
      @model_overrides = model_overrides
      @base_degreedays_temperature = 30.0
      @super_debug = false
      @heating_model_override = model_overrides
    end

    def holidays
      @meter.meter_collection.holidays
    end

    def temperatures
      @meter.meter_collection.temperatures
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.r2_statistics
      { # r2 range => stats, rating
        0.0...0.1 => { percent: 0.06,   rating: :very_poor,          rating_value: 0 },
        0.1...0.2 => { percent: 0.03,   rating: :very_poor,          rating_value: 1 },
        0.2...0.3 => { percent: 0.03,   rating: :very_poor,          rating_value: 2 },
        0.3...0.4 => { percent: 0.02,   rating: :poor,               rating_value: 4 },
        0.4...0.5 => { percent: 0.13,   rating: :below_average,      rating_value: 5 },
        0.5...0.6 => { percent: 0.23,   rating: :just_below_average, rating_value: 7 },
        0.6...0.7 => { percent: 0.16,   rating: :about_average,      rating_value: 7 },
        0.7...0.8 => { percent: 0.23,   rating: :above_average,      rating_value: 8 },
        0.8...0.9 => { percent: 0.10,   rating: :excellent,          rating_value: 9 },
        0.9..1.0  => { percent: 0.00,   rating: :perfect,            rating_value: 10 }
      }
    end

    def self.r2_rating_adjective(r2)
      I18nHelper.adjective( find_r2_rating(r2, :rating) )
    end

    def self.r2_rating_out_of_10(r2)
      find_r2_rating(r2, :rating_value)
    end

    def self.average_schools_r2
      0.62
    end

    def self.find_r2_rating(r2, parameter)
      r2_statistics.select { |r2_range, _stats| r2_range.include?(r2) }.values[0][parameter]
    end

    # avoid using name as ambiguous, use urn
    def self.example_good_r2_school
      { name: 'Bishop Sutton Primary School', urn: 109061 }
    end

    # avoid using name as ambiguous, use urn
    def self.example_poor_r2_school
      { name: 'Freshford Primary School', urn: 109195 }
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.school_heating_days_statistics
      { # days range => stats, rating
        0...90    => { percent: 0.10,   rating: :perfect,              rating_value: 10 },
        90...100  => { percent: 0.20,   rating: :excellent,            rating_value: 10 },
        100...110 => { percent: 0.07,   rating: :good,                 rating_value: 9 },
        110...120 => { percent: 0.23,   rating: :better_than_average,  rating_value: 7 },
        120...130 => { percent: 0.23,   rating: :about_average,        rating_value: 4 },
        130...140 => { percent: 0.10,   rating: :worse_than_average,   rating_value: 3 },
        140...150 => { percent: 0.0,    rating: :poor,                 rating_value: 2 },
        150..365  => { percent: 0.10,   rating: :very_poor,            rating_value: 0 },
      }
    end

    def self.school_heating_day_adjective(days)
      I18nHelper.adjective( find_school_day_rating(days, :rating) )
    end

    def self.school_day_heating_rating_out_of_10(days)
      find_school_day_rating(days, :rating_value)
    end

    def self.find_school_day_rating(days, parameter)
      school_heating_days_statistics.select { |days_range, _stats| days_range.include?(days) }.values.dig(0, parameter)
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.average_school_heating_days
      115
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.non_school_heating_days_statistics
      { # days range => stats, rating
        0...5     => { percent: 0.07,   rating: :perfect,              rating_value: 10  },
        5...10    => { percent: 0.11,   rating: :excellent,            rating_value:  9  },
        10...15   => { percent: 0.04,   rating: :good,                 rating_value:  8  },
        15...20   => { percent: 0.11,   rating: :better_than_average,  rating_value:  7  },
        20...25   => { percent: 0.29,   rating: :about_average,        rating_value:  6  },
        25...30   => { percent: 0.14,   rating: :worse_than_average,   rating_value:  5  },
        30...35   => { percent: 0.0,    rating: :poor,                 rating_value:  4  },
        35...40   => { percent: 0.07,   rating: :poor,                 rating_value:  3  },
        40...50   => { percent: 0.04,   rating: :very_poor,            rating_value:  2  },
        50...70   => { percent: 0.07,   rating: :very_poor,            rating_value:  1  },
        70...300  => { percent: 0.07,   rating: :bad,                  rating_value:  0  }
      }
    end

    def self.non_school_heating_day_adjective(days)
      I18nHelper.adjective( non_find_school_day_rating(days, :rating) )
    end

    def self.non_school_day_heating_rating_out_of_10(days)
      non_find_school_day_rating(days, :rating_value)
    end

    def self.non_find_school_day_rating(days, parameter)
      non_school_heating_days_statistics.select { |days_range, _stats| days_range.include?(days) }
                                        .values.dig(0, parameter)
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.average_non_school_day_heating_days
      24
    end

    def calculate_regression_model(_period, _allow_more_than_1_year, _non_heating_model)
      raise EnergySparksAbstractBaseClass.new('Failed attempt to call calculate_regression_model() on abstract base class of HeatingModel')
    end

    def heating_on?(_date)
      raise EnergySparksAbstractBaseClass.new('Failed attempt to call heating_on?() on abstract base class of HeatingModel')
    end

    def predicted_kwh(date, temperature)
      raise EnergySparksAbstractBaseClass.new('Failed attempt to call predicted_kwh()predicted_kwh on abstract base class of HeatingModel')
    end

    def predicted_kwh_list_of_dates(list_of_dates, temperatures)
      total_kwh = 0.0
      list_of_dates.map do |date|
        temperature = temperatures.average_temperature(date)
        predicted_kwh(date, temperature)
      end
    end

    def name
      raise EnergySparksAbstractBaseClass.new('Failed attempt to call name() on abstract base class of HeatingModel')
    end

    def kwh_saving_for_1_C_thermostat_reduction(start_date, end_date)
      total_kwh = 0.0
      (start_date..end_date).each do |date|
        if heating_on?(date) && !weekend?(date)
          model_type = model_type?(date)
          # deal with schools with perfect holiday/weekend heating management - mainly switched off
          next if %i[holiday_heating weekend_heating].include?(model_type) && @models[model_type].nil?
          kwh_sensitivity = -@models[model_type].b
          _offset = @models[model_type].a
          total_kwh += kwh_sensitivity
        end
      end
      total_kwh
    end

    # PH was in 2 minds how to do this, whether to include
    # hot water summer use temperature adjustment
    # but ultimately decided on balance to only adjust when
    # the heating was on
    def heating_change_statistics(previous_year_range, last_year_range)
      return nil if previous_year_range.first < @amr_data.start_date

      previous_year_average_heating_temperature = average_temperature_when_heating_on(previous_year_range.first, previous_year_range.last)
      last_year_average_heating_temperature     = average_temperature_when_heating_on(last_year_range.first, last_year_range.last)
      change_in_average_heating_temperature     = last_year_average_heating_temperature - previous_year_average_heating_temperature
      impact_1c_change_kwh = -kwh_saving_for_1_C_thermostat_reduction(previous_year_range.first, previous_year_range.last)
      kwh_impact = impact_1c_change_kwh * change_in_average_heating_temperature
      last_year_kwh     = @amr_data.kwh_date_range(last_year_range.first, last_year_range.last)
      previous_year_kwh = @amr_data.kwh_date_range(previous_year_range.first, previous_year_range.last)
      adjusted_previous_year_kwh = previous_year_kwh + kwh_impact

      {
        last_year: {
          average_heating_temperature: last_year_average_heating_temperature,
          annual_kwh:                  last_year_kwh
        },
        previous_year: {
          average_heating_temperature: previous_year_average_heating_temperature,
          annual_kwh:                  previous_year_kwh,
          adjust_kwh:                  kwh_impact,
          adjusted_annual_kwh:         adjusted_previous_year_kwh
        },
        change: {
          temperature:          change_in_average_heating_temperature,
          kwh:                  last_year_kwh - previous_year_kwh,
          adjusted_kwh:         last_year_kwh - adjusted_previous_year_kwh,
          percent:              (last_year_kwh - previous_year_kwh) / previous_year_kwh,
          adjusted_percent:     (last_year_kwh - adjusted_previous_year_kwh) / adjusted_previous_year_kwh,
          impact_1c_change_kwh: impact_1c_change_kwh
        }
      }
    end

    def heating_on_dates(start_date, end_date)
      (start_date..end_date).map do |date|
        heating_on?(date) ? date : nil
      end.compact
    end

    def average_temperature_when_heating_on(start_date, end_date)
      heating_on_temperatures = heating_on_dates(start_date, end_date).map do |date|
        temperatures.average_temperature(date)
      end

      heating_on_temperatures.sum / heating_on_temperatures.length
    end

    def hot_water_poor_insulation_cost_kwh(start_date, end_date, max_non_hotwater_criteria = 50.0)
      calculation = hot_water_analysis(start_date, end_date, max_non_hotwater_criteria)
      calculation.nil? ? [0.0, 0.0] : [calculation[:annual_sensitivity_to_insulation_kwh], calculation[:percent_base_hot_water_usage]]
    end

    private def hotwater_in_period?(model_type, max_non_hotwater_criteria)
      return false unless @models.key?(model_type)
      crude_hw_estimate_kwh_per_day = @models[model_type].predicted_kwh_temperature(20.0)
      crude_hw_estimate_kwh_per_day > max_non_hotwater_criteria
    end

    def hot_water_analysis(start_date, end_date, max_non_hotwater_criteria = 50.0)
      return nil if @meter.heating_only? || !@models.key?(:summer_occupied_all_days) || !@models.key?(:holiday_hotwater_only)

      temperature_sensitivity_kwh_per_c = -1.0 * @models[:summer_occupied_all_days].b
      base_hotwater_usage_at_20c = @models[:summer_occupied_all_days].predicted_kwh_temperature(20.0)
      holiday_hotwater_usage_at_20c = @models[:holiday_hotwater_only].predicted_kwh_temperature(20.0)

      holiday_hotwater = hotwater_in_period?(:holiday_hotwater_only, max_non_hotwater_criteria)
      weekend_hotwater = hotwater_in_period?(:weekend_hotwater_only, max_non_hotwater_criteria)

      temperature_sensitivity_kwh = 0.0
      base_hot_water_usage = 0.0
      total_heating_on_kwh = 0.0
      total_heating_off_kwh = 0.0
      hot_water_kwh_in_heating_period = 0.0

      (start_date..end_date).each do |date|
        if (weekend?(date) && weekend_hotwater) ||
           (holiday?(date) && holiday_hotwater) ||
           occupied?(date)

          avg_temp = temperatures.average_temperature(date)
          temperature_sensitivity_kwh += temperature_sensitivity_kwh_per_c * [20.0 - avg_temp, 0.0].max
          base_hot_water_usage += base_hotwater_usage_at_20c

          unless boiler_off?(date)
            if heating_on?(date)
              total_heating_on_kwh += @amr_data.one_day_kwh(date)
              hot_water_kwh_in_heating_period += base_hotwater_usage_at_20c
            else
              total_heating_off_kwh += @amr_data.one_day_kwh(date)
            end
          end
        end
      end
      sensivitity_kwh = [temperature_sensitivity_kwh, 0.0].max
      percent_base_hot_water_usage = sensivitity_kwh / (sensivitity_kwh + base_hot_water_usage)
      hot_water_kwh = total_heating_off_kwh + hot_water_kwh_in_heating_period
      heating_kwh = total_heating_on_kwh - hot_water_kwh_in_heating_period
      hot_water_efficiency = (base_hotwater_usage_at_20c - holiday_hotwater_usage_at_20c) / base_hotwater_usage_at_20c
      hot_water_efficiency *= HotwaterModel::SEASONALBOILEREFFICIENCY

      {
        annual_sensitivity_to_insulation_kwh: sensivitity_kwh,
        percent_base_hot_water_usage:         percent_base_hot_water_usage,
        annual_heating_kwh:                   heating_kwh,
        annual_hotwater_kwh:                  hot_water_kwh,
        daily_hotwater_usage_kwh:             base_hotwater_usage_at_20c,
        daily_holiday_hotwater_usage_kwh:     holiday_hotwater_usage_at_20c,
        hot_water_efficiency:                 hot_water_efficiency
      }
    end

    def heating_category(date, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
      if heating_on?(date)
        if holiday?(date)
          :holiday_heating_on
        elsif weekend?(date)
          :weekend_heating_on
        else
          recommended = within_recommended_heating_period(date, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
          recommended ? :schoolday_heating_on_recommended : :schoolday_heating_on_not_recommended
        end
      else
        :other_days
      end
    end

    def within_recommended_heating_period(date, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
      toy = TimeOfYear.to_toy(date)
      TimeOfYear.within_period(toy, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
    end

    def heating_day_breakdown(start_date, end_date, doy_recommended_heating_start_date = TimeOfYear.new(10,28), doy_recommended_heating_doy_end_date = TimeOfYear.new(4,5))
      kwhs = {
        schoolday_heating_on_recommended: 0.0,
        schoolday_heating_on_not_recommended: 0.0,
        weekend_heating_on: 0.0,
        holiday_heating_on: 0.0,
        other_days: 0.0
      }
      (start_date..end_date).each do |date|
        heating_cat = heating_category(date, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
        kwhs[heating_cat] += @amr_data.one_day_kwh(date)
      end
      kwhs
    end

    def occupied?(date)
      !weekend?(date) && !holiday?(date)
    end

    def weekend?(date)
      DateTimeHelper.weekend?(date)
    end

    def holiday?(date)
      holidays.holiday?(date)
    end

    def report_missing_amr_dates(missing_dates)
      logger.info 'Warning: missing dates during regression modelling'
      # rubocop:disable Naming/VariableNumber
      missing_dates.each_slice(10) do |group_of_10|
        logger.info group_of_10.to_s
      end
      # rubocop:enable Naming/VariableNumber
    end

    def save_raw_regression_data_to_csv_for_debug(filename, x1, y1, a, b, r2)
      filepath = File.join(File.dirname(__FILE__), '../../../log/' + filename)
      File.open(filepath, 'w') do |file|
        file.puts "#{a}, #{b}, #{r2}"
        file.puts
        x1.length.times do |i|
          file.puts "#{x1[i]}, #{y1[i]}"
        end
      end
    end

    def sorted_model_keys(models)
      models.sort_by { |k, _v| models_ordered[k]}
    end

    # not ideal, but needed for tabular html advice presentation
    def models_ordered
      model_sort_order1 = {
        summer_occupied_all_days: 0,
        heating_occupied_all_days: 1
      }
      doy_models = HeatingModelTemperatureSpaceThermalMass::SCHOOLDAYHEATINGMODELTYPES
      model_sort_order2 = doy_models.each_with_index.map { |model_type, i| [model_type, i + 2] }.to_h
      model_sort_order3 = {
        weekend_heating:       7,
        holiday_heating:       8,
        weekend_hotwater_only: 9,
        holiday_hotwater_only: 10,
        none:                  11
      }
      model_sort_order1.merge(model_sort_order2.merge(model_sort_order3))
    end

    def all_heating_model_types
      %i[heating_occupied_all_days weekend_heating holiday_heating] + HeatingModelTemperatureSpaceThermalMass::SCHOOLDAYHEATINGMODELTYPES
    end
  end

  #=====================================================================================
  # alternative model for fitting, in temperature space not degree days
  class HeatingModelTemperatureSpace < HeatingModel
    class ScalingModelCalculationDoesntCoverAllModelTypes < StandardError; end
    HEATINGOCCUPIEDMODEL = :heating_occupied_all_days
    HEATINGWEEKENDMODEL = :weekend_heating
    HEATINGHOLIDAYMODEL = :holiday_heating
    SCHOOLDAYHEATINGMODELTYPES = [HEATINGOCCUPIEDMODEL]
    HEATINGMODELTYPES = [HEATINGOCCUPIEDMODEL,  HEATINGWEEKENDMODEL, HEATINGHOLIDAYMODEL].freeze
    ALLMODELTYPES = %i[heating_occupied_all_days weekend_heating holiday_heating
                      summer_occupied_all_days holiday_hotwater_only weekend_hotwater_only none].freeze
    attr_reader :standard_deviation, :standard_deviation_percent, :model_calculation_time
    attr_reader :non_heating_model

    def initialize(heat_meter, model_overrides)
      super(heat_meter, model_overrides)
      @base_degreedays_temperature = 50.0
      @max_zero_daily_kwh = 20.0
      @heat_meter = heat_meter
      @heating_on_periods = nil
      @models = {}
      @cached_model_type = {}
    end

    def name
      'Simple'
    end

    def thermally_massive?
      false
    end

    def all_heating_model_types
      ALLMODELTYPES
    end

    def winter_heating_model_types
      SCHOOLDAYHEATINGMODELTYPES
    end

    def school_day_heating_model?(model_type)
      winter_heating_model_types.include?(model_type)
    end

    def includes_school_day_heating_models?
      @models.keys.any? { |model_type| school_day_heating_model?(model_type) }
    end

    def heating_model?(model_type)
      all_heating_model_types.include?(model_type)
    end

    def model(type)
      @models[type]
    end

    def winter_heating_samples
      samples(:heating_occupied_all_days)
    end

    def summer_occupied_day_samples
      samples(:summer_occupied_all_days)
    end

    def samples(model_type)
      model(model_type).nil? ? 0 : model(model_type).samples
    end

    def minimum_samples_for_model_to_run_well
      MINIMUM_SAMPLES_FOR_SIMPLE_MODEL_TO_RUN_WELL
    end

    # 35/60 value needs further research across multiple schools
    def enough_samples_for_good_fit
      if no_heating?
        summer_occupied_day_samples > MINIMUM_NON_HEATING_MODEL_SAMPLES
      else
        winter_heating_samples > minimum_samples_for_model_to_run_well
      end
    end

    # returns a hash to value, or hash of information relating to the model
    # for debugging or presentation
    def model_configuration
      results = {
        'School Name'                 =>    @heat_meter.meter_collection.name,
        'Floor Area'                  =>    [@heat_meter.meter_collection.floor_area, :float_0dp],
        'Pupils'                      =>    [@heat_meter.meter_collection.number_of_pupils, :integer],
        'Max summer kWh'              =>    [non_heating_model.average_max_non_heating_day_kwh, :kwh],
        'Non heating model'           =>    [non_heating_model.class.name, :string],
        'Standard Deviation'          =>    [@standard_deviation, :kwh],
        'Standard Deviation Percent'  =>    [@standard_deviation_percent, :percent],
        'Balance Point Temperature'   =>    [average_base_temperature,  :temperature],
        'Average R2'                  =>    [average_heating_school_day_r2, :float_1dp],
        'School Heating Days'         =>    [number_of_heating_school_days, :integer],
        'Non School Day Heating Days' =>    [number_of_non_school_heating_days, :integer],
        'Days of meter readings'      =>    [(@amr_data.end_date - @amr_data.start_date + 1).to_i, :integer],
        'Model calculation time (ms)' =>    [(@model_calculation_time * 1000.0).to_i, :integer],
      }

      results.merge!(regression_model_configuration)

      results
    end

    def regression_model_configuration
      @models.transform_values do |model|
        model.configuration
      end
    end

    def models?
      !@models.empty?
    end

    # uses a crude optimum start model to work out the benefit of starting the boiler at a good time
    # in the morning depending on the outside temperature
    # the result is really an 'up to figure' as doesn't take into account thermal mass,
    # which will have to wait for the building simulation model
    # and doesn't include pre-midnight startup costs TODO(PH, 12Apr19)
    def one_year_saving_from_better_boiler_start_time(asof_date, datatype)
      start_date = [@heat_meter.amr_data.start_date, asof_date - 365].max
      total_saving = 0.0
      (start_date..asof_date).each do |date|
        _actual_on_time, _start_time, _temperature, kwh_saving = heating_on_time_assessment(date, datatype)
        total_saving += kwh_saving.nil? ? 0.0 : kwh_saving
      end
      # not particularly effective if data shortage doesn't cover the heating season!
      normalisation_factor_for_less_than_one_years_data = 365 / (asof_date - start_date)
      total_saving *= normalisation_factor_for_less_than_one_years_data
      [total_saving, total_saving / @heat_meter.amr_data.kwh_date_range(start_date, asof_date, datatype)]
    end

    def heating_on_time_assessment(date, datatype = :kwh)
      temperature = temperatures.average_temperature_in_time_range(date, 0, 10).round(1) # between midnight and 5:00am
      return [nil, nil, temperature, nil] if !heating_on?(date)

      heating_on_halfhour_index = heating_on_half_hour_index(date)
      return [nil, nil, temperature, nil] if heating_on_halfhour_index.nil?

      days_data = @heat_meter.amr_data.days_kwh_x48(date, datatype)
      actual_on_time = heating_on_halfhour_index.nil? ? nil : TimeOfDay.time_of_day_from_halfhour_index(heating_on_halfhour_index)
      recommended_start_time, recommended_start_time_halfhour_index = recommended_optimum_start_time(nil, temperature)
      started_too_early = heating_on_halfhour_index < recommended_start_time_halfhour_index
      kwh_saving = started_too_early ? days_data[heating_on_halfhour_index..recommended_start_time_halfhour_index].sum : 0.0

      [actual_on_time, recommended_start_time, temperature, kwh_saving]
    end

    def heating_on_time(date)
      hhi = heating_on_half_hour_index(date)

      return nil if hhi.nil?

      TimeOfDay.time_of_day_from_halfhour_index(hhi)
    end

    def heating_on_half_hour_index_checked(date, ignore_frosty_days_temperature: nil)
      return Float::NAN unless heating_on?(date)

      return Float::NAN if frosty_morning?(date, ignore_frosty_days_temperature)

      heating_on_half_hour_index(date)
    end

    def frosty_morning?(date, frost_temperature)
      return false if frost_temperature.nil?

      # assume heating comes on at 5am normally, so only test temperature before 5am
      # TODO(PH, 14Mar20202): consider more nuanced if temperature dips below a frost
      #                       temperature during the morning period prior to the heating
      #                       normally coming on?
      temperatures.average_temperature_in_time_range(date, 0, 10) < frost_temperature
    end

    def heating_on_half_hour_index(date)
      baseload_kw   = @heat_meter.amr_data.statistical_baseload_kw(date)
      peakload_kw   = @heat_meter.amr_data.statistical_peak_kw(date)
      half_load_kwh = (baseload_kw + ((peakload_kw - baseload_kw) * 0.5)) / 2.0
      days_data = @heat_meter.amr_data.days_kwh_x48(date)
      days_data.index{ |kwh| kwh > half_load_kwh }
    end

    # perhaps needs merging with def heating_on_time_assessment, but not in this test cycle TODO(PH, 25Jul2020)
    def heating_on_date_time?(date, halfhour_index, criteria_percent_baseload_to_peak = 0.2)
      baseload_kw = @heat_meter.amr_data.statistical_baseload_kw(date)
      peakload_kw = @heat_meter.amr_data.statistical_peak_kw(date)
      min_load_kw = baseload_kw + ((peakload_kw - baseload_kw) * criteria_percent_baseload_to_peak)
      @heat_meter.amr_data.kw(date, halfhour_index) > min_load_kw
    end

    def one_year_start_date
      [@amr_data.start_date, @amr_data.end_date - 364, temperatures.start_date].max
    end

    def one_year_end_date
      [@amr_data.end_date, temperatures.end_date].min
    end


    def optimum_start_analysis(start_date: one_year_start_date, end_date: one_year_end_date, days_of_the_week: nil, months_of_year: nil)
      start_time_temperature_pairs = optimum_start_times_temperatures(start_date, end_date, days_of_the_week, months_of_year)
      return nil_optimum_start_model_result if start_time_temperature_pairs.empty?

      # print_optimum_start_times_temperatures(start_time_temperature_pairs)

      calculate_optimum_start_regression(start_time_temperature_pairs)
    end

    def nil_optimum_start_model_result
      {
        regression_start_time:        nil,
        optimum_start_sensitivity:    nil,
        regression_r2:                nil,
        average_start_time:           nil,
        start_time_standard_devation: nil,
        days:                         0
      }
    end

    def calculate_optimum_start_regression(time_temp_pairs)
      start_times = time_temp_pairs.map(&:first)
      x = Daru::Vector.new(start_times)
      y = Daru::Vector.new(time_temp_pairs.map(&:last))
      sr = Statsample::Regression.simple(x, y)

      {
        regression_start_time:        sr.a,
        optimum_start_sensitivity:    sr.b,
        regression_r2:                sr.r2,
        average_start_time:           start_times.sum / start_times.length,
        start_time_standard_devation: EnergySparks::Maths.standard_deviation(start_times),
        days:                         time_temp_pairs.length
      }
    end

    def print_optimum_start_times_temperatures(data)
      data.each do |time_temp_pair|
        puts "#{time_temp_pair[0].round(2)} #{time_temp_pair[1].round(2)}"
      end
    end

    def optimum_start_times_temperatures(start_date, end_date, days_of_the_week, months)
      start_times = (start_date..end_date).map do |date|
        if !days_of_the_week.nil? && !days_of_the_week.include?(date.wday)
          nil
        elsif !months.nil? && !months.include?(date.month)
          nil
        else
          on_time, _recommend_time, temperature, _kwh_saving = heating_on_time_assessment(date)
          on_time.nil? ? nil : [on_time.hours_fraction, temperature]
        end
      end.compact
    end

    private def recommended_optimum_start_time(_date, temperature)
      optimum_start_regression = { # [temperature] => hours past midnight
        3.9 => 0.0,   # in weather below 4C (frost) turn heating on early
        4.0 => 3.5,   # in weather at or below 0.0C turning heating on a 3:30am
        10.0 => 6.5   # in weather at 10.0C turn heating on at 6:30am
      }
      interpolation = Interpolate::Points.new(optimum_start_regression)
      start_time = interpolation.at(temperature)
      #previously we calculated time of day using start_time * 2.0. but this produces overly
      #precise timings, e.g. 05.02, 03:57, 03:38, which we can't confidently use or display
      #to users. So we now round to the half-hourly index, which aligns better with our
      #prediction of when heating is on, which is only to an hh index.
      [TimeOfDay.time_of_day_from_halfhour_index((start_time * 2).to_i), (start_time * 2).to_i]
    end

    def model_configuration_pairs_format
      pairs = {}
      model_configuration.each do |name, value|
        if value.is_a?(String)
          pairs[name] = value
        elsif value.is_a?(Array)
          pairs[name] = value[0]
        elsif value.is_a?(Hash)
          value.each do |name2, value2|
            pairs[name.to_s + ':' + name2.to_s] = value2[0]
          end
        end
      end
      pairs
    end

    def model_configuration_csv_format
      pairs = model_configuration_pairs_format
      [pairs.keys, pairs.values]
    end

    private def check_model_fitting_start_end_dates(period, allow_more_than_1_year)
      return unless @model_overrides.fitting.nil?
      days = period.end_date - period.start_date + 1
      if !allow_more_than_1_year && (days > 365 || days < 362)
        logger.info "Error: regression model fitting should only be over a year, got #{days}"
        raise EnergySparksUnexpectedStateException, "Error: regression model fitting should only be over a year, got #{days}"
      end
    end

    def non_heating_model_type_description
      HeatingNonHeatingDisaggregationModelBase.model_type_description(:best, @heat_meter, @model_overrides)
    end

    def calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type = nil)
      # check_model_fitting_start_end_dates(period, allow_more_than_1_year)

      bm = Benchmark.realtime {
        @non_heating_model = HeatingNonHeatingDisaggregationModelBase.model_factory(non_heating_model_type, @heat_meter, @model_overrides)
        @heating_model_period = period
        @non_heating_model.calculate_max_summer_hotwater_kitchen_kwh(period)
        x_data, y_data = assign_models(period)
        calculate_regressions(x_data, y_data)
        calculate_base_temperatures
      }
      @model_calculation_time = bm
      @standard_deviation, @standard_deviation_percent = standard_deviation_from_model(period.start_date, period.end_date)
      @cached_model_type = {}
    end

    def assign_models(period)
      x_data = {}
      y_data = {}
      (period.start_date..period.end_date).each do |date|
        if @amr_data.date_exists?(date)
          model_type = model_type?(date)
          (x_data[model_type] ||= []).push(temperatures.average_temperature(date))
          (y_data[model_type] ||= []).push(@amr_data.one_day_kwh(date))
        end
      end
      [x_data, y_data]
    end

    def standard_deviation_from_model(start_date, end_date)
      differences = []
      (start_date..end_date).each do |date|
        if @amr_data.date_exists?(date)
          differences.push(@amr_data.one_day_kwh(date) - predicted_kwh(date, temperatures.average_temperature(date)))
        end
      end
      sd = EnergySparks::Maths.standard_deviation(differences)
      avg_kwh = @amr_data.average_in_date_range_ignore_missing(start_date, end_date)
      [sd, sd/avg_kwh]
    end

    def calculate_regressions(x_data, y_data)
      logger.info "Regression model calculation result for #{self.class.name}"
      x_data.each_key do |model_type|
        @models[model_type] = regression(model_type, x_data[model_type], y_data[model_type])
        logger.info "#{model_type}: #{@models[model_type]}"
      end
    end

    def model_type?(date)
      model_type = @cached_model_type[date]
      return model_type unless model_type.nil?
      @cached_model_type[date] = model_type_slow_lookup?(date)
    end

    def model_type_slow_lookup?(date)
      model_type = @cached_model_type[date]
      return model_type unless model_type.nil?
      model_type = if boiler_off?(date)
          :none
        elsif @meter.heating_only?
          heating_on?(date) ? winter_model(date) : :none
        elsif @meter.kitchen_only?
          kitchen_model(date)
        elsif @meter.hot_water_only?
          summer_model(date)
        else
          heating_on?(date) ? winter_model(date) : summer_model(date)
        end
      logger.info "Missing model type for date #{date}" if model_type.nil?
      model_type
    end

    private def no_heating?
      @meter.kitchen_only? || @meter.hot_water_only?
    end

    private def choose_by_day_type(date, occupied, weekend, holiday)
      if occupied?(date)
        occupied.is_a?(Symbol) ? occupied : occupied.call(date) # defer func eval until know its occupied
      elsif holiday?(date)
        holiday
      elsif weekend?(date)
        weekend
      else
        raise EnergySparksUnexpectedStateException.new("Unexpected uncatagorised date #{date}")
      end
    end

    private def winter_model(date)
      choose_by_day_type(date, method(:school_day_model), HEATINGWEEKENDMODEL, HEATINGHOLIDAYMODEL)
    end

    public def summer_model(date)
      choose_by_day_type(date, :summer_occupied_all_days, :weekend_hotwater_only, :holiday_hotwater_only)
    end

    private def kitchen_model(date)
      choose_by_day_type(date, :summer_occupied_all_days, :none, :none)
    end

    protected def school_day_model(date)
      HEATINGOCCUPIEDMODEL
    end

    # should only be called for heating model types
    # as code limits max predicted model estimate to base temperature
    def calculate_base_temperatures
      self.class::HEATINGMODELTYPES.each do |model_type|
        if @models.key?(model_type)
          base_temp = calculate_base_temperature_by_parameter(model_type)
          @models[model_type].base_temperature = base_temp
        end
      end
    end

    def average_base_temperature
      calculate_base_temperature_by_parameter(HEATINGOCCUPIEDMODEL)
    end

    def number_of_heating_school_days
      @meter.non_heating_only? ? Float::NAN : @models[HEATINGOCCUPIEDMODEL].samples
    end

    def average_heating_school_day_a
      @meter.non_heating_only? ? Float::NAN : @models[HEATINGOCCUPIEDMODEL].a
    end

    def average_heating_school_day_b
      @meter.non_heating_only? ? Float::NAN : @models[HEATINGOCCUPIEDMODEL].b
    end

    def average_heating_school_day_r2
      @meter.non_heating_only? ? Float::NAN : @models[HEATINGOCCUPIEDMODEL].r2
    end

    def number_of_non_school_heating_days
      weekend_days = @models[HEATINGWEEKENDMODEL].nil? ? 0 : @models[HEATINGWEEKENDMODEL].samples
      holidays = @models[HEATINGHOLIDAYMODEL].nil? ? 0 : @models[HEATINGHOLIDAYMODEL].samples
      logger.info "Weekend model:  #{@models[HEATINGWEEKENDMODEL]}"
      logger.info "Holiday model:  #{@models[HEATINGHOLIDAYMODEL]}"
      weekend_days + holidays
    end

    def number_of_non_school_heating_days_method_b(start_date, end_date, gas_meter_noise_kwh_day = 25.0)
      count = 0
      (start_date..end_date).each do |date|
        unless occupied?(date)
          count += 1 if @amr_data.one_day_kwh(date) > (@non_heating_model.max_non_heating_day_kwh(date)
 + gas_meter_noise_kwh_day)
        end
      end
      count
    end

    def number_of_heating_days_method_b(start_date, end_date)
      number_of_heating_school_days + number_of_non_school_heating_days_method_b(start_date, end_date)
    end

    def number_of_heating_days
      number_of_heating_school_days + number_of_non_school_heating_days
    end

    def calculate_base_temperature_by_parameter(winter_model_parameter)
      base_temperature = nil
      winter_model = @models[winter_model_parameter]
      summer_model = @models[:summer_occupied_all_days]

      if winter_model.nil?
        return nil if summer_model.nil?

        base_temperature = - summer_model.a / summer_model.b
      else
        if summer_model.nil?
          base_temperature = - winter_model.a / winter_model.b
        else
          base_temperature = (winter_model.a - summer_model.a) / (summer_model.b - winter_model.b)
        end
      end

      base_temperature
    end

    def regression(model_name, x1, y1)
      if x1.empty? || x1.length == 1
        logger.warn "Warning: empty data set for calculating regression for #{model_name}"
        error = x1.empty? ? 'Warning: zero vector' : 'Warning: vector of length 1'
        return RegressionModelTemperature.new(model_name, error, 0.0, 0.0, 0.0, 0, nil, nil)
      end

      x = Daru::Vector.new(x1)
      y = Daru::Vector.new(y1)
      sr = Statsample::Regression.simple(x, y)
      model = RegressionModelTemperature.new(model_name, model_name.to_s, sr.a, sr.b, sr.r2, x1.length, x1, y1)

      logger.info "Calculating regression for #{model_name}: a = #{model.a} b = #{model.b} r2 = #{model.r2} x #{model.samples}"

      if @super_debug
        filename = model_name.to_s + ' ' + DateTime.now.strftime('%Y%m%d%H%M%3N') + '.csv'
        save_raw_regression_data_to_csv_for_debug(filename, x1, y1, sr.a, sr.b, sr.r2)
      end

      model
    end

    def configure_models
      logger.info "HeatingModelTemperatureSpace.configure_models() - do nothing"
    end

    def boiler_off?(date)
      @amr_data.date_missing?(date) || @amr_data.one_day_kwh(date) < @max_zero_daily_kwh
    end

    def boiler_on?(date)
      !@amr_data.date_missing?(date) && @amr_data.one_day_kwh(date) >= @max_zero_daily_kwh
    end

    # see Energy Sparks\Energy Sparks Project Team Documents\Analytics\Modelling\Reassessment of Seasonal Heating Control.gdoc
    # return as method as could eventually be dynamic, but hard code from CONSTANT for the moment
    # increased to 13 after reviewing seasonal control analysis - https://trello.com/c/rn2Vs1xK/4483-the-seasonal-control-page-seems-to-suggest-that-glenmoor-academy-is-using-a-lot-of-heating-in-warmer-weather-it-flags-up-days-in
    BALANCE_POINT_TEMPERATURE = 13.0 # used by alerts

    def balance_point_temperature(_date)
      BALANCE_POINT_TEMPERATURE
    end

    def heating_on_seasonal_type(date)
      if heating_on?(date)
        temperature = temperatures.average_temperature(date)
        if temperature > balance_point_temperature(date)
          :heating_warm_weather
        else
          :heating_cold_weather
        end
      else
        :heating_off
      end
    end

    def percent_hot_water(date)
      return 0.0 if @models[:summer_occupied_all_days].nil?

      total_usage = @amr_data.one_day_kwh(date)

      return nil if total_usage.zero?

      hot_water_kwh = @models[:summer_occupied_all_days].predicted_kwh_temperature(temperatures.average_temperature(date))

      percent = hot_water_kwh / total_usage

      [[percent, 0.0].max, 1.0].min
    end

    def heating_on_seasonal_analysis(start_date: [@amr_data.end_date - 365, @amr_data.start_date].max, end_date: @amr_data.end_date, split_out_hotwater: true)
      analysis = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = Hash.new { |h, k| h[k] = 0.0 } } }

      (start_date..end_date).each do |date|
        day_type  = holidays.day_type(date)
        heat_type = heating_on_seasonal_type(date)

        %i[kwh £ £current co2].each do |data_type|
          if split_out_hotwater
            bdown = heating_breakdown(date, data_type)
            bdown.each do |heating_type, val|
              analysis[day_type][heating_type][data_type] += val
            end
          else
            analysis[day_type][heat_type][data_type] += @amr_data.one_day_kwh(date, data_type)
          end
        end

        analysis[day_type][heat_type][:days] += 1
        analysis[day_type][heat_type][:degree_days] += temperatures.degree_days(date)
      end

      analysis
    end

    def heating_breakdown(date, data_type)
      heat_type = heating_on_seasonal_type(date)
      total = @amr_data.one_day_kwh(date, data_type)

      if heat_type == :heating_off
        {
          heating_cold_weather: 0.0,
          heating_off:          total
        }
      else
        # co2 and £ datatype linear for gas so kWh based disaggregation
        # acceptable, storage heaters not relevant as no HW
        pct_hw = percent_hot_water(date)

        {
          heat_type =>   total * (1.0 - pct_hw),
          heating_off:   total * pct_hw
        }
      end
    end

    def heating_on?(date)
      @amr_data.date_exists?(date) && @amr_data.one_day_kwh(date) > @non_heating_model.max_non_heating_day_kwh(date)
    end

    def heat_on_missing_data?(date)
      # more fault tolerant version of above to meter validation
      # attempts to work out from chronologically close by readings
      # whether heating is on in circumstance data is missing on date

      if @heating_on_periods.nil?
        calculate_heating_periods(@amr_data.start_date, @amr_data.end_date) if @heating_on_periods.nil?
        # consolidate_heating_periods(@heating_on_periods)
      end
      !SchoolDatePeriod.find_period_for_date(date, @heating_on_periods).nil?
    end

    # the code can get confused if the heating or amr data is intermittant and can assume
    # during the winter that the heating has gone off, so for meter validation purposes
    # this heuristic method is employed to consolidate the heating_on_periods
    def consolidate_heating_periods(heating_on_periods)
      df = '%a %d-%b-%Y'
      logger.info "Original heating periods #{@heat_meter.mpan_mprn}"
      heating_on_periods.each do |heating_period|
        logger.info "#{heating_period.start_date.strftime(df)} #{heating_period.start_date.strftime(df)}"
      end
    end

    # scan through the daily consumption data, using the regression information
    # to determine the heating periods
    # returning a list of the heating periods
    def calculate_heating_periods(start_date, end_date)
      heating_on = false
      @heating_on_periods = []
      heating_start_date = start_date

      logger.info "Calculating Heating Periods between #{start_date} and #{end_date} for #{@heat_meter.mpan_mprn}"
      previous_date = start_date
      missing_dates = []

      (start_date..end_date).each do |date|
        begin
          if @amr_data.date_exists?(date)
            next if weekend?(date) # skip weekends, i.e. work out heating day ranges for school days and holidays only

            kwh_today = @amr_data.one_day_kwh(date)
            temperature = temperatures.average_temperature(date)
            if kwh_today > @non_heating_model.max_non_heating_day_kwh(date) && !heating_on
              # puts "heating on  transition #{date.strftime('%a %d-%b-%Y')} #{kwh_today.round(0)} v #{@non_heating_model.max_non_heating_day_kwh(date)}"
              heating_on = true
              heating_start_date = date
            elsif kwh_today <= @non_heating_model.max_non_heating_day_kwh(date) && heating_on
              # puts "heating off transition #{date.strftime('%a %d-%b-%Y')} #{kwh_today.round(0)} v #{@non_heating_model.max_non_heating_day_kwh(date)}"
              heating_on = false
              heating_period = SchoolDatePeriod.new(:heatingperiod, 'N/A', heating_start_date, previous_date)
              @heating_on_periods.push(heating_period)
            end
            previous_date = date
          else
            missing_dates.push(date)
          end
        rescue StandardError => e
          logger.error e
        end
      end
      if heating_on
        heating_period = SchoolDatePeriod.new(:heatingperiod, 'N/A', heating_start_date, end_date)
        @heating_on_periods.push(heating_period)
      end

      logger.info "#{@heating_on_periods.length} heating periods"
      @heating_on_periods
    end

    def regression_model_parameters(date)
      model = @models[model_type?(date)]
      {
        a:                model.a,
        b:                model.b,
        r2:               model.r2,
        base_temperature: model.base_temperature,
        model_name:       model.key,
        heating_on:       heating_on?(date)
      }
    end

    # community use is generally signifcantly lower than overall usage
    # so use the overall usage for the modelling but scale down
    # proportionally to the community use - not ideal but
    # there isn't a better solution
    def community_use_model_scaling_factor(date, community_use)
      @community_use_model_scaling_factors ||= calculate_community_use_model_scaling_factors(community_use)
      raise ScalingModelCalculationDoesntCoverAllModelTypes, "Extend sd, ed calc below to cover #{date}" unless @community_use_model_scaling_factors.key?(model_type?(date))
      @community_use_model_scaling_factors[model_type?(date)]
    end

    def no_scaling_models
      @models.transform_values { |_v| 1.0 }
    end

    def calculate_community_use_model_scaling_factors(community_use)
      return no_scaling_models if community_use.nil?

      # don't go back more than a year to calculate the scaling factors
      # slight risk model type not represent in this period and exception thrown above
      end_date   = @heating_model_period.end_date
      # see ScalingModelCalculationDoesntCoverAllModelTypes exception above
      start_date = [@heating_model_period.start_date, end_date - 365].max

      scaling_factor_by_model_type = {}

      (start_date..end_date).each do |date|
        model_type = model_type?(date)
        scaling_factor_by_model_type[model_type] ||= []
        day_kwh       = @amr_data.one_day_kwh(date, :kwh, community_use: nil)
        community_kwh = @amr_data.one_day_kwh(date, :kwh, community_use: community_use)
        scaling_factor_by_model_type[model_type].push([community_kwh, day_kwh])
      end

      scaling_factor_by_model_type.transform_values do |kwhs|
        kwhs.map { |kk| kk[0] }.sum / kwhs.map { |kk| kk[1] }.sum
      end
    end

    def temperature_compensated_one_day_gas_kwh(from_date, to_temperature, from_kwh = @amr_data.one_day_kwh(from_date), floor, community_use: nil)
      model_type = model_type?(from_date)
      model = @models[model_type]
      return from_kwh if model_type == :none && model.nil?
      from_temperature = temperatures.average_temperature(from_date)
      scale = community_use_model_scaling_factor(from_date, community_use)
      to_kwh = from_kwh + scale * model.b * (to_temperature - from_temperature)
      floor.nil? ? to_kwh : [to_kwh, 0.0].max
    end

    def predicted_kwh(date, temperature, substitute_model_date = nil)
      model = @models[model_type?(substitute_model_date.nil? ? date : substitute_model_date)]
      if model.nil?
        logger.warn "Unable to predict kwh as no model #{model_type?(date)} for #{date} using zero, only #{@models.keys} available"
        0.0
      elsif !model.valid?
        logger.warn "Unable to predict kwh as model not valid for #{date} using zero"
        0.0
      else
        model.predicted_kwh_temperature(temperature)
      end
    end

    def predicted_kwh_for_future_date(heating_on, date, temperature)
      if heating_on
        predicted_heating_kwh_future_date(date, temperature)
      else
        predicted_non_heating_kwh_future_date(date, temperature)
      end
    end

    # used by heating on/off alert when its using a forecast, so it doesn't know whether the heating is on or not
    def predicted_heating_kwh_future_date(date, temperature)
      model = @models[heating_model_for_future_date(date)]
      return 0.0 if model.nil? # generally assume this when for example heating completely off at weekends or holidays
      model.predicted_kwh_temperature(temperature)
    end

    def average_heating_b_kwh_per_1_C_per_day
      @models[HEATINGOCCUPIEDMODEL].b
    end

    # used by heating on/off alert when its using a forecast, so it doesn't know whether the heating is on or not
    def predicted_non_heating_kwh_future_date(date, temperature)
      model = @models[non_heating_model_for_future_date(date)]
      return 0.0 if model.nil? # generally assume this when for example hot water completely off at weekends or holidays
      model.predicted_kwh_temperature(temperature)
    end

    def heating_model_for_future_date(date)
      holiday?(date) ? HEATINGHOLIDAYMODEL : weekend?(date) ? HEATINGWEEKENDMODEL : HEATINGOCCUPIEDMODEL
    end

    def non_heating_model_for_future_date(date)
      holiday?(date) ? :holiday_hotwater_only : weekend?(date) ? :weekend_hotwater_only : :summer_occupied_all_days
    end

    def predicted_kwh_daterange(start_date, end_date, temperatures)
      total_kwh = 0.0
      (start_date..end_date).each do |date|
        temperature = temperatures.average_temperature(date)
        total_kwh += predicted_kwh(date, temperature)
      end
      total_kwh
    end

    def temperature_from_degreedays(degree_days)
      @base_degreedays_temperature - degree_days
    end

    def degreedays_from_temperature(temperature)
      [0, @base_degreedays_temperature - temperature].max
    end
  end

  # heavy thermal mass (day of week) version of temperature space regression model
  class HeatingModelTemperatureSpaceThermalMass < HeatingModelTemperatureSpace
    SCHOOLDAYHEATINGMODELTYPES = %i[heating_occupied_monday heating_occupied_tuesday heating_occupied_wednesday heating_occupied_thursday heating_occupied_friday].freeze
    HEATINGMODELTYPES = SCHOOLDAYHEATINGMODELTYPES + [HEATINGWEEKENDMODEL, HEATINGHOLIDAYMODEL]
    ALLMODELTYPES = %i[heating_occupied_monday heating_occupied_tuesday heating_occupied_wednesday heating_occupied_thursday heating_occupied_friday
                      weekend_heating holiday_heating
                      summer_occupied_all_days holiday_hotwater_only weekend_hotwater_only none].freeze
    def initialize(heat_meter, model_overrides)
      super(heat_meter, model_overrides)
    end

    def name
      'Thermally massive'
    end

    def thermally_massive?
      true
    end

    def heating_model_for_future_date(date)
      holiday?(date) ? HEATINGHOLIDAYMODEL : weekend?(date) ? HEATINGWEEKENDMODEL : school_day_model(date)
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
      raise EnergySparksUnexpectedStateException.new("Unexpected weekend date #{date}") if date.saturday? || date.sunday?
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

  module SharedManuallyConfiguredMultipleInheritanceCode
    attr_reader :reason
    def initialize(heat_meter, model_overrides)
      super(heat_meter, model_overrides)

      @reason = model_overrides.reason
      model_overrides.override_regression_model[:regression_models].each do |key, model|
        m = HeatingModel::RegressionModelTemperatureManuallyConfigured.new(
          key,
          key.to_s,
          model[:a].to_f,
          model[:b].to_f,
          model[:base_temperature].to_f
        )
        @models[key] = m
      end
    end

    def name
      'Overridden'
    end

    def enough_samples_for_good_fit
      true
    end

    # just assign sample data, don't calculate model as manually set
    def calculate_regression_model(period, _allow_more_than_1_year, _non_heating_model)
      bm = Benchmark.realtime {
        x_data, y_data = assign_models(period)
        x_data.each do |model_type, samples|
          if @models.key?(model_type)
            @models[model_type].samples = samples.length
            @models[model_type].x = samples
            @models[model_type].y = y_data[model_type]
          end
        end
        @standard_deviation, @standard_deviation_percent = standard_deviation_from_model(period.start_date, period.end_date)
      }
      @model_calculation_time = bm
    end
  end

  # manually configured version of simple model, data held in meter attributes
  class HeatingModelTemperatureSpaceManuallyConfigured < HeatingModelTemperatureSpace
    include SharedManuallyConfiguredMultipleInheritanceCode
  end
    # manually configured version of therally heavy model, data held in meter attributes
  class HeatingModelThermalMassingModeTemperatureSpaceManuallyConfigured < HeatingModelTemperatureSpaceThermalMass
    include SharedManuallyConfiguredMultipleInheritanceCode
  end
end

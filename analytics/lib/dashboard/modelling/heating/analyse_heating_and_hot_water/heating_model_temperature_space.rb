require_relative 'heating_model'
require_relative 'heating_model/regression_model_temperature'

module AnalyseHeatingAndHotWater
  #=====================================================================================
  # alternative model for fitting, in temperature space not degree days
  class HeatingModelTemperatureSpace < HeatingModel
    class ScalingModelCalculationDoesntCoverAllModelTypes < StandardError; end

    HEATINGOCCUPIEDMODEL = :heating_occupied_all_days
    HEATINGWEEKENDMODEL = :weekend_heating
    HEATINGHOLIDAYMODEL = :holiday_heating
    SCHOOLDAYHEATINGMODELTYPES = [HEATINGOCCUPIEDMODEL]
    HEATINGMODELTYPES = [HEATINGOCCUPIEDMODEL, HEATINGWEEKENDMODEL, HEATINGHOLIDAYMODEL].freeze
    ALLMODELTYPES = %i[heating_occupied_all_days weekend_heating holiday_heating
                       summer_occupied_all_days holiday_hotwater_only weekend_hotwater_only none].freeze
    attr_reader :standard_deviation, :standard_deviation_percent, :model_calculation_time, :non_heating_model

    def initialize(heat_meter, model_overrides)
      super
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
        'School Name' => @heat_meter.meter_collection.name,
        'Floor Area' => [@heat_meter.meter_collection.floor_area, :float_0dp],
        'Pupils' => [@heat_meter.meter_collection.number_of_pupils, :integer],
        'Max summer kWh' => [non_heating_model.average_max_non_heating_day_kwh, :kwh],
        'Non heating model' => [non_heating_model.class.name, :string],
        'Standard Deviation' => [@standard_deviation, :kwh],
        'Standard Deviation Percent' => [@standard_deviation_percent, :percent],
        'Balance Point Temperature' => [average_base_temperature, :temperature],
        'Average R2' => [average_heating_school_day_r2, :float_1dp],
        'School Heating Days' => [number_of_heating_school_days, :integer],
        'Non School Day Heating Days' => [number_of_non_school_heating_days, :integer],
        'Days of meter readings' => [(@amr_data.end_date - @amr_data.start_date + 1).to_i, :integer],
        'Model calculation time (ms)' => [(@model_calculation_time * 1000.0).to_i, :integer]
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
      return [nil, nil, temperature, nil] unless heating_on?(date)

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
      days_data.index { |kwh| kwh > half_load_kwh }
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

    def optimum_start_analysis(start_date: one_year_start_date, end_date: one_year_end_date, days_of_the_week: nil,
                               months_of_year: nil)
      start_time_temperature_pairs = optimum_start_times_temperatures(start_date, end_date, days_of_the_week,
                                                                      months_of_year)
      return nil_optimum_start_model_result if start_time_temperature_pairs.empty?

      # print_optimum_start_times_temperatures(start_time_temperature_pairs)

      calculate_optimum_start_regression(start_time_temperature_pairs)
    end

    def nil_optimum_start_model_result
      {
        regression_start_time: nil,
        optimum_start_sensitivity: nil,
        regression_r2: nil,
        average_start_time: nil,
        start_time_standard_devation: nil,
        days: 0
      }
    end

    def calculate_optimum_start_regression(time_temp_pairs)
      start_times = time_temp_pairs.map(&:first)
      x = Daru::Vector.new(start_times)
      y = Daru::Vector.new(time_temp_pairs.map(&:last))
      sr = Statsample::Regression.simple(x, y)

      {
        regression_start_time: sr.a,
        optimum_start_sensitivity: sr.b,
        regression_r2: sr.r2,
        average_start_time: start_times.sum / start_times.length,
        start_time_standard_devation: EnergySparks::Maths.standard_deviation(start_times),
        days: time_temp_pairs.length
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
      # previously we calculated time of day using start_time * 2.0. but this produces overly
      # precise timings, e.g. 05.02, 03:57, 03:38, which we can't confidently use or display
      # to users. So we now round to the half-hourly index, which aligns better with our
      # prediction of when heating is on, which is only to an hh index.
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
      return unless !allow_more_than_1_year && (days > 365 || days < 362)

      logger.debug { "Error: regression model fitting should only be over a year, got #{days}" }
      raise EnergySparksUnexpectedStateException,
            "Error: regression model fitting should only be over a year, got #{days}"
    end

    def non_heating_model_type_description
      HeatingNonHeatingDisaggregationModelBase.model_type_description(:best, @heat_meter, @model_overrides)
    end

    def calculate_regression_model(period, allow_more_than_1_year, non_heating_model_type = nil)
      # check_model_fitting_start_end_dates(period, allow_more_than_1_year)

      bm = Benchmark.realtime do
        @non_heating_model = HeatingNonHeatingDisaggregationModelBase.model_factory(non_heating_model_type,
                                                                                    @heat_meter, @model_overrides)
        @heating_model_period = period
        @non_heating_model.calculate_max_summer_hotwater_kitchen_kwh(period)
        x_data, y_data = assign_models(period)
        calculate_regressions(x_data, y_data)
        calculate_base_temperatures
      end
      @model_calculation_time = bm
      @standard_deviation, @standard_deviation_percent = standard_deviation_from_model(period.start_date,
                                                                                       period.end_date)
      @cached_model_type = {}
    end

    def assign_models(period)
      x_data = {}
      y_data = {}
      (period.start_date..period.end_date).each do |date|
        next unless @amr_data.date_exists?(date)

        model_type = model_type?(date)
        (x_data[model_type] ||= []).push(temperatures.average_temperature(date))
        (y_data[model_type] ||= []).push(@amr_data.one_day_kwh(date))
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
      [sd, sd / avg_kwh]
    end

    def calculate_regressions(x_data, y_data)
      logger.debug { "Regression model calculation result for #{self.class.name}" }
      x_data.each_key do |model_type|
        @models[model_type] = regression(model_type, x_data[model_type], y_data[model_type])
        logger.debug { "#{model_type}: #{@models[model_type]}" }
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
      logger.debug { "Missing model type for date #{date}" } if model_type.nil?
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
      logger.debug { "Weekend model:  #{@models[HEATINGWEEKENDMODEL]}" }
      logger.debug { "Holiday model:  #{@models[HEATINGHOLIDAYMODEL]}" }
      weekend_days + holidays
    end

    def number_of_non_school_heating_days_method_b(start_date, end_date, gas_meter_noise_kwh_day = 25.0)
      count = 0
      (start_date..end_date).each do |date|
        if !occupied?(date) && (@amr_data.one_day_kwh(date) > (@non_heating_model.max_non_heating_day_kwh(date)
                                                               + gas_meter_noise_kwh_day))
          count += 1
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
        base_temperature = if summer_model.nil?
                             - winter_model.a / winter_model.b
                           else
                             (winter_model.a - summer_model.a) / (summer_model.b - winter_model.b)
                           end
      end

      base_temperature
    end

    def regression(model_name, x1, y1)
      if x1.empty? || x1.length == 1
        logger.warn { "Warning: empty data set for calculating regression for #{model_name}" }
        error = x1.empty? ? 'Warning: zero vector' : 'Warning: vector of length 1'
        return RegressionModelTemperature.new(model_name, error, 0.0, 0.0, 0.0, 0, nil, nil)
      end

      x = Daru::Vector.new(x1)
      y = Daru::Vector.new(y1)
      sr = Statsample::Regression.simple(x, y)
      model = RegressionModelTemperature.new(model_name, model_name.to_s, sr.a, sr.b, sr.r2, x1.length, x1, y1)

      logger.debug do
        "Calculating regression for #{model_name}: a = #{model.a} b = #{model.b} r2 = #{model.r2} x #{model.samples}"
      end

      model
    end

    def configure_models
      logger.info 'HeatingModelTemperatureSpace.configure_models() - do nothing'
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

    def heating_on_seasonal_analysis(start_date: [@amr_data.end_date - 365, @amr_data.start_date].max,
                                     end_date: @amr_data.end_date, split_out_hotwater: true)
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
          heating_off: total
        }
      else
        # co2 and £ datatype linear for gas so kWh based disaggregation
        # acceptable, storage heaters not relevant as no HW
        pct_hw = percent_hot_water(date)

        {
          heat_type => total * (1.0 - pct_hw),
          heating_off: total * pct_hw
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
        calculate_heating_periods(@amr_data.start_date, @amr_data.end_date)
        # consolidate_heating_periods(@heating_on_periods)
      end
      !SchoolDatePeriod.find_period_for_date(date, @heating_on_periods).nil?
    end

    # the code can get confused if the heating or amr data is intermittant and can assume
    # during the winter that the heating has gone off, so for meter validation purposes
    # this heuristic method is employed to consolidate the heating_on_periods
    def consolidate_heating_periods(heating_on_periods)
      df = '%a %d-%b-%Y'
      logger.debug { "Original heating periods #{@heat_meter.mpan_mprn}" }
      heating_on_periods.each do |heating_period|
        logger.debug { "#{heating_period.start_date.strftime(df)} #{heating_period.start_date.strftime(df)}" }
      end
    end

    # scan through the daily consumption data, using the regression information
    # to determine the heating periods
    # returning a list of the heating periods
    def calculate_heating_periods(start_date, end_date)
      heating_on = false
      @heating_on_periods = []
      heating_start_date = start_date

      logger.debug { "Calculating Heating Periods between #{start_date} and #{end_date} for #{@heat_meter.mpan_mprn}" }
      previous_date = start_date
      missing_dates = []

      (start_date..end_date).each do |date|
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
      if heating_on
        heating_period = SchoolDatePeriod.new(:heatingperiod, 'N/A', heating_start_date, end_date)
        @heating_on_periods.push(heating_period)
      end

      logger.debug { "#{@heating_on_periods.length} heating periods" }
      @heating_on_periods
    end

    def regression_model_parameters(date)
      model = @models[model_type?(date)]
      {
        a: model.a,
        b: model.b,
        r2: model.r2,
        base_temperature: model.base_temperature,
        model_name: model.key,
        heating_on: heating_on?(date)
      }
    end

    # community use is generally signifcantly lower than overall usage
    # so use the overall usage for the modelling but scale down
    # proportionally to the community use - not ideal but
    # there isn't a better solution
    def community_use_model_scaling_factor(date, community_use)
      @community_use_model_scaling_factors ||= calculate_community_use_model_scaling_factors(community_use)
      unless @community_use_model_scaling_factors.key?(model_type?(date))
        raise ScalingModelCalculationDoesntCoverAllModelTypes,
              "Extend sd, ed calc below to cover #{date}"
      end

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

    def temperature_compensated_one_day_gas_kwh(from_date, to_temperature, from_kwh = @amr_data.one_day_kwh(from_date),
                                                floor, community_use: nil)
      model_type = model_type?(from_date)
      model = @models[model_type]
      return from_kwh if model_type == :none && model.nil?

      from_temperature = temperatures.average_temperature(from_date)
      scale = community_use_model_scaling_factor(from_date, community_use)
      to_kwh = from_kwh + (scale * model.b * (to_temperature - from_temperature))
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
      if holiday?(date)
        HEATINGHOLIDAYMODEL
      else
        weekend?(date) ? HEATINGWEEKENDMODEL : HEATINGOCCUPIEDMODEL
      end
    end

    def non_heating_model_for_future_date(date)
      if holiday?(date)
        :holiday_hotwater_only
      else
        weekend?(date) ? :weekend_hotwater_only : :summer_occupied_all_days
      end
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
end

# older heating regression models temperarily deprecated
require_relative 'heating_model'
require_relative 'heating_model/regression_model'

module AnalyseHeatingAndHotWater
   # the simplest model: same regression for all days of a week when heating on
   class BasicRegressionHeatingModel < HeatingModel
    include Logging

    def initialize(amr_data, holidays, temperatures, meter_attributes_moved_to_meter = nil)
      super(amr_data, holidays, temperatures, meter_attributes_moved_to_meter)
      @models = {}
      @heating_on_periods = []
      @day_to_model_map = {} # [date] = model()
      @heating_days_of_week_parameters = nil
    end

    def name
      'Simple Heating Model'
    end

    def model(type)
      @models[type]
    end

    def configure_models(defined_months)
      @winter_months = defined_months ? [11, 12, 1, 2, 3] : nil
      @summer_months = [5, 6, 7, 8]
      heating_degreeday_base = @base_degreedays_temperature
      puts "Using #{heating_degreeday_base}"
      summer_degreeday_base = 50
      # different models for different types of days
      # slightly complicated by how a heating day is calculated:
      # - initially by assuming a restricted list of winter months
      # - then using this modelling to more generally apply to shoulder months
      #   based on using the heating consumption to determine whether the heating is on or not...
      @model_config = { # days of week, months, occupied, base temperature, heating on
        heating_occupied_all_days:  [[1, 2, 3, 4, 5], @winter_months, true,   heating_degreeday_base, true],
        winter_weekend:             [[0, 6],          @winter_months, false,  heating_degreeday_base, true],
        winter_holiday:             [[1, 2, 3, 4, 5], @winter_months, false,  heating_degreeday_base, true],
        summer_occupied_all_days:   [[1, 2, 3, 4, 5], @summer_months, true,   summer_degreeday_base, false],
        summer_weekend:             [[0, 6],          @summer_months, false,  summer_degreeday_base, false],
        summer_holiday:             [[1, 2, 3, 4, 5], @summer_months, false,  summer_degreeday_base, false]
      }
    end

    def full_regression_model_calculation(period, temperature = @base_degreedays_temperature,
      delimination_method = @heating_day_determination_method, delimination_parameter = @heating_day_determination_method)

      default_delimination_method = @heating_day_determination_method
      default_delimination_value = delimination_parameter
      begin
        set_heating_delimination_method(delimination_method, delimination_parameter)

        if delimination_method == :fixed__minimum_per_day
          # only need to go through calc cycle once as can already determine a heating day
          calculate_regression_model(period, false)
          calculate_heating_periods(period.start_date, period.end_date)
        else

          # first calculate heating model crudely by assuming heating is on only during fixed winter months
          calculate_regression_model(period, true)
          calculate_heating_periods(period.start_date, period.end_date)
          print_heating_model_results

          # then once the regression model is crudely defined, repeat but for a broader range
          # of dates where the heating period is defined by the daily heating kWh
          # i.e. will include heating periods in shoulder months

          # calculate the regresion again, but using heating periods determined by the previous model calculation
          # rather than fixed winter months
          calculate_regression_model(period, false)
          # then calculate the heating periods again with this more refined regression model
          calculate_heating_periods(period.start_date, period.end_date)
          print_heating_model_results
          sd, mean, actual, predicted = cusum_standard_deviation_average
          logger.info "2: mean #{mean} standard deviation #{sd} actual kwh #{actual} predicted #{predicted}"

          @heating_day_determination_method = :percent_regression_model_prediction
          @heating_day_determination_method_parameter = 0.5
          calculate_heating_periods(period.start_date, period.end_date)
          calculate_regression_model(period, false)

          print_heating_model_results
        end
      rescue StandardError => e
        logger.error 'Error in calculating regression model'
        logger.error e
      end
      # put object/default values back to proginal object settings
      set_heating_delimination_method(default_delimination_method, default_delimination_value)
    end

    def print_heating_model_results
      @models.each do |model_param, results|
        l = sprintf('Results of model calculation (%-26.26s) %5.0f %5.0f %0.3f %4d %3.1f',
                model_param, results.a, results.b, results.r2, results.samples, results.base_temperature)
        logger.info l
      end
    end

    def calculate_regression_model(period, defined_months = true)
      configure_models(defined_months)

      bm = Benchmark.measure {
        @model_config.each do |group_name, config|
          @models[group_name] = regression_filtered(
            group_name.to_s,
            "#{group_name.to_s} DDbaseT=#{config[3]}",
            config[2],  # occupied
            period,
            config[1],  # months
            config[4],  # heating on test
            config[0],  # days of week
            config[3]   # degreeday base
          )
          puts "#{group_name} #{config}"
          # puts @models[group_name].inspect
        end
      }
      @models.each do |name, model|
        a = model.a + model.b * model.base_temperature
        b = - model.b
        puts "#{name}: #{model.a} #{model.b} #{model.r2}"
        puts "#{name}: in T #{a} #{b}"
      end
      puts "model calc time #{bm.to_s}"
    end

    def heating_day_minimum_kwh(date, temperature)
      # puts "heating_day_minimum_kwh: #{date} #{temperature} #{@heating_day_determination_method} #{@heating_day_determination_method_parameter}"
      case @heating_day_determination_method
      when :prediction_at_fixed_degreedays
        if @heating_day_determination_method_parameter.nil?
          @models[:heating_occupied_all_days].predicted_kwh_degreedays(0.0)
        else
          @models[:heating_occupied_all_days].predicted_kwh_degreedays(@heating_day_determination_method_parameter)
        end
      when :percent_regression_model_prediction
        @models[:heating_occupied_all_days].predicted_kwh_degreedays(temperature) * @heating_day_determination_method_parameter
      when :zero_heating_only
        if @heating_day_determination_method_parameter.nil?
          0.0 # heating only meter - perhaps too suspectible to noise?
        else
          @heating_day_determination_method_parameter # hard coded kWh/day
        end
      when 'Fixed winter months'
        [11, 12, 1, 2, 3].include?(date.month) ? 0.0 : Float::INFINITY # TODO (PH,22Nov2018) fudge
      else
        raise EnergySparksUnexpectedStateException.new("Unexpected heating day determination method >#{@heating_day_determination_method}<")
      end
    end

    def heating_on?(date)
      !SchoolDatePeriod.find_period_for_date(date, @heating_on_periods).nil?
    end

    def predicted_kwh(date, temperature)
      @models[model_type?(date)].predicted_kwh_temperature(temperature)
    end

    def model_type?(date)
      if heating_on?(date) && occupied?(date)
        winter_weekday_occupied_model_type?(date)
      elsif [10, 11, 12, 1, 2, 3].include?(date.month)  # winter
        if weekend?(date)
          :winter_weekend
        elsif holiday?(date)
          :winter_holiday
        else
          # logger.info "Unclassified winter daily regression model date #{date}"
          # :heating_occupied_all_days
          winter_weekday_occupied_model_type?(date)
        end
      else # summer
        if occupied?(date)
          :summer_occupied_all_days
        elsif holiday?(date)
          :summer_holiday
        elsif weekend?(date)
          :summer_weekend
        else
          # logger.info "Unclassified summer daily regression model date 2 #{date}"
          :summer_occupied_all_days
        end
      end
    end

    def winter_weekday_occupied_model_type?(_date)
      :heating_occupied_all_days
    end

    def predicted_kwh_daterange(start_date, end_date, temperatures)
      total_kwh = 0.0
      (start_date..end_date).each do |date|
        temperature = temperatures.average_temperature(date)
        total_kwh += predicted_kwh(date, temperature)
      end
      total_kwh
    end

    def predicted_kwh_list_of_dates(list_of_dates, temperatures)
      total_kwh = 0.0
      list_of_dates.each do |date|
        temperature = temperatures.average_temperature(date)
        total_kwh += predicted_kwh(date, temperature)
      end
      total_kwh
    end
  end
end

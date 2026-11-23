require_relative 'heating_non_heating_disaggregation_model_base'

module AnalyseHeatingAndHotWater
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
end

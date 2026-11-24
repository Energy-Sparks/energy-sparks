require_relative '../analyse_heating_and_hot_water'

module AnalyseHeatingAndHotWater
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

    attr_reader :models, :heating_on_periods, :heating_days_of_week_parameters, :model_config
    attr_accessor :base_degreedays_temperature

    def initialize(meter, model_overrides)
      @amr_data = meter.amr_data
      @meter = meter
      @model_overrides = model_overrides
      @base_degreedays_temperature = 30.0
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
        0.9..1.0 => { percent: 0.00, rating: :perfect,            rating_value: 10 }
      }
    end

    def self.r2_rating_adjective(r2)
      I18nHelper.adjective(find_r2_rating(r2, :rating))
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
      { name: 'Bishop Sutton Primary School', urn: 109_061 }
    end

    # avoid using name as ambiguous, use urn
    def self.example_poor_r2_school
      { name: 'Freshford Primary School', urn: 109_195 }
    end

    # based on analysis of 31 schools from 16Feb2019
    def self.school_heating_days_statistics
      { # days range => stats, rating
        0...90 => { percent: 0.10, rating: :perfect,              rating_value: 10 },
        90...100 => { percent: 0.20, rating: :excellent, rating_value: 10 },
        100...110 => { percent: 0.07,   rating: :good,                 rating_value: 9 },
        110...120 => { percent: 0.23,   rating: :better_than_average,  rating_value: 7 },
        120...130 => { percent: 0.23,   rating: :about_average,        rating_value: 4 },
        130...140 => { percent: 0.10,   rating: :worse_than_average,   rating_value: 3 },
        140...150 => { percent: 0.0,    rating: :poor,                 rating_value: 2 },
        150..365 => { percent: 0.10, rating: :very_poor, rating_value: 0 }
      }
    end

    def self.school_heating_day_adjective(days)
      I18nHelper.adjective(find_school_day_rating(days, :rating))
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
        0...5 => { percent: 0.07, rating: :perfect, rating_value: 10 },
        5...10 => { percent: 0.11, rating: :excellent, rating_value: 9 },
        10...15 => { percent: 0.04,   rating: :good,                 rating_value:  8  },
        15...20 => { percent: 0.11,   rating: :better_than_average,  rating_value:  7  },
        20...25 => { percent: 0.29,   rating: :about_average,        rating_value:  6  },
        25...30 => { percent: 0.14,   rating: :worse_than_average,   rating_value:  5  },
        30...35 => { percent: 0.0,    rating: :poor,                 rating_value:  4  },
        35...40 => { percent: 0.07,   rating: :poor,                 rating_value:  3  },
        40...50 => { percent: 0.04,   rating: :very_poor,            rating_value:  2  },
        50...70 => { percent: 0.07,   rating: :very_poor,            rating_value:  1  },
        70...300 => { percent: 0.07, rating: :bad, rating_value: 0 }
      }
    end

    def self.non_school_heating_day_adjective(days)
      I18nHelper.adjective(non_find_school_day_rating(days, :rating))
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
        next unless heating_on?(date) && !weekend?(date)

        model_type = model_type?(date)
        # deal with schools with perfect holiday/weekend heating management - mainly switched off
        next if %i[holiday_heating weekend_heating].include?(model_type) && @models[model_type].nil?

        kwh_sensitivity = -@models[model_type].b
        _offset = @models[model_type].a
        total_kwh += kwh_sensitivity
      end
      total_kwh
    end

    # PH was in 2 minds how to do this, whether to include
    # hot water summer use temperature adjustment
    # but ultimately decided on balance to only adjust when
    # the heating was on
    def heating_change_statistics(previous_year_range, last_year_range)
      return nil if previous_year_range.first < @amr_data.start_date

      previous_year_average_heating_temperature = average_temperature_when_heating_on(previous_year_range.first,
                                                                                      previous_year_range.last)
      last_year_average_heating_temperature     = average_temperature_when_heating_on(last_year_range.first,
                                                                                      last_year_range.last)
      change_in_average_heating_temperature = last_year_average_heating_temperature - previous_year_average_heating_temperature
      impact_1c_change_kwh = -kwh_saving_for_1_C_thermostat_reduction(previous_year_range.first,
                                                                      previous_year_range.last)
      kwh_impact = impact_1c_change_kwh * change_in_average_heating_temperature
      last_year_kwh     = @amr_data.kwh_date_range(last_year_range.first, last_year_range.last)
      previous_year_kwh = @amr_data.kwh_date_range(previous_year_range.first, previous_year_range.last)
      adjusted_previous_year_kwh = previous_year_kwh + kwh_impact

      {
        last_year: {
          average_heating_temperature: last_year_average_heating_temperature,
          annual_kwh: last_year_kwh
        },
        previous_year: {
          average_heating_temperature: previous_year_average_heating_temperature,
          annual_kwh: previous_year_kwh,
          adjust_kwh: kwh_impact,
          adjusted_annual_kwh: adjusted_previous_year_kwh
        },
        change: {
          temperature: change_in_average_heating_temperature,
          kwh: last_year_kwh - previous_year_kwh,
          adjusted_kwh: last_year_kwh - adjusted_previous_year_kwh,
          percent: (last_year_kwh - previous_year_kwh) / previous_year_kwh,
          adjusted_percent: (last_year_kwh - adjusted_previous_year_kwh) / adjusted_previous_year_kwh,
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
      if calculation.nil?
        [0.0,
         0.0]
      else
        [calculation[:annual_sensitivity_to_insulation_kwh],
         calculation[:percent_base_hot_water_usage]]
      end
    end

    private def hotwater_in_period?(model_type, max_non_hotwater_criteria)
      return false unless @models.key?(model_type)

      crude_hw_estimate_kwh_per_day = @models[model_type].predicted_kwh_temperature(20.0)
      crude_hw_estimate_kwh_per_day > max_non_hotwater_criteria
    end

    def hot_water_analysis(start_date, end_date, max_non_hotwater_criteria = 50.0)
      if @meter.heating_only? || !@models.key?(:summer_occupied_all_days) || !@models.key?(:holiday_hotwater_only)
        return nil
      end

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
        next unless (weekend?(date) && weekend_hotwater) ||
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
      sensivitity_kwh = [temperature_sensitivity_kwh, 0.0].max
      percent_base_hot_water_usage = sensivitity_kwh / (sensivitity_kwh + base_hot_water_usage)
      hot_water_kwh = total_heating_off_kwh + hot_water_kwh_in_heating_period
      heating_kwh = total_heating_on_kwh - hot_water_kwh_in_heating_period
      hot_water_efficiency = (base_hotwater_usage_at_20c - holiday_hotwater_usage_at_20c) / base_hotwater_usage_at_20c
      hot_water_efficiency *= HotwaterModel::SEASONALBOILEREFFICIENCY

      {
        annual_sensitivity_to_insulation_kwh: sensivitity_kwh,
        percent_base_hot_water_usage: percent_base_hot_water_usage,
        annual_heating_kwh: heating_kwh,
        annual_hotwater_kwh: hot_water_kwh,
        daily_hotwater_usage_kwh: base_hotwater_usage_at_20c,
        daily_holiday_hotwater_usage_kwh: holiday_hotwater_usage_at_20c,
        hot_water_efficiency: hot_water_efficiency
      }
    end

    def heating_category(date, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
      if heating_on?(date)
        if holiday?(date)
          :holiday_heating_on
        elsif weekend?(date)
          :weekend_heating_on
        else
          recommended = within_recommended_heating_period(date, doy_recommended_heating_start_date,
                                                          doy_recommended_heating_doy_end_date)
          recommended ? :schoolday_heating_on_recommended : :schoolday_heating_on_not_recommended
        end
      else
        :other_days
      end
    end

    def within_recommended_heating_period(date, doy_recommended_heating_start_date,
                                          doy_recommended_heating_doy_end_date)
      toy = TimeOfYear.to_toy(date)
      TimeOfYear.within_period(toy, doy_recommended_heating_start_date, doy_recommended_heating_doy_end_date)
    end

    def heating_day_breakdown(start_date, end_date, doy_recommended_heating_start_date = TimeOfYear.new(10, 28),
                              doy_recommended_heating_doy_end_date = TimeOfYear.new(4, 5))
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

    delegate :weekend?, to: :DateTimeHelper

    delegate :holiday?, to: :holidays

    def report_missing_amr_dates(missing_dates)
      logger.debug { 'Warning: missing dates during regression modelling' }
      missing_dates.each_slice(10) do |group_of_10|
        logger.debug { group_of_10.to_s }
      end
    end

    def sorted_model_keys(models)
      models.sort_by { |k, _v| models_ordered[k] }
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
        weekend_heating: 7,
        holiday_heating: 8,
        weekend_hotwater_only: 9,
        holiday_hotwater_only: 10,
        none: 11
      }
      model_sort_order1.merge(model_sort_order2.merge(model_sort_order3))
    end

    def all_heating_model_types
      %i[heating_occupied_all_days weekend_heating holiday_heating] + HeatingModelTemperatureSpaceThermalMass::SCHOOLDAYHEATINGMODELTYPES
    end

    # older heating regression models temperarily deprecated
    # deprecated methods

        # if called with list of months, just tests whether within those months
    # else if nil, then bases heating test on calculated min kwh defining heating might be
    # on, or reverse if heating_on_test = false (false for summer/non-heating periods)
    def heating_on_off_test(date, list_of_months, heating_on_test)
      kwh_today = @amr_data.one_day_kwh(date)
      heating_on_off = nil
      if list_of_months.nil?
        temperature = @temperatures.average_temperature(date)
        min_kwh_for_heat_on = heating_day_minimum_kwh(date, temperature)
        heating_on_off = heating_on_test ? (kwh_today >= min_kwh_for_heat_on) : (kwh_today < min_kwh_for_heat_on)
      else
        heating_on_off = list_of_months.include?(date.month)
      end
      heating_on_off
    end

    def regression(key, regression_model_name, x1, y1, degreeday_base_temperature)
      if x1.empty?
        logger.error "Error: empty data set for calculating regression"
        return RegressionModel.new(key, "Error: zero vector", 0.0, 0.0, 0.0, degreeday_base_temperature, 0, nil, nil)
      end
      x = Daru::Vector.new(x1)
      y = Daru::Vector.new(y1)
      sr = Statsample::Regression.simple(x, y)
      model = RegressionModel.new(key, regression_model_name, sr.a, sr.b, sr.r2, degreeday_base_temperature, x1.length, x1, y1)

      if @super_debug
        filename = regression_model_name + ' ' + degreeday_base_temperature.to_s + ' ' + DateTime.now.strftime('%Y%m%d%H%M%3N') + '.csv'
        save_raw_regression_data_to_csv_for_debug(filename, x1, y1, sr.a, sr.b, sr.r2)
      end

      model
    end

    def regression_filtered(key, regression_model_name, occupied, period, list_of_months, heating_on_test, days_of_week, degreeday_base_temperature, min_kwh = 20.0, max_kwh = nil)
      degree_days = []
      days_kwh = []

      missing_dates = []
      (period.start_date..period.end_date).each do |date|

        # apply 3 tests, in performance order - so structure of code to maximise performance
        if days_of_week.include?(date.wday) && occupied?(date) == occupied
          begin
            if heating_on_off_test(date, list_of_months, heating_on_test)
              kwh_today = @amr_data.one_day_kwh(date)
              if kwh_today > min_kwh && (max_kwh.nil? || kwh_today < max_kwh) # filter out small usage, assume close to zero
                degree_days.push(@temperatures.degree_days(date, degreeday_base_temperature))
                days_kwh.push(kwh_today)
              end
            end
          rescue StandardError => _e
            missing_dates.push(date.strftime('%a%d%b%Y'))
          end
        end
      end

      report_missing_amr_dates(missing_dates) if !missing_dates.empty?

      regression(key, regression_model_name, degree_days, days_kwh, degreeday_base_temperature)
    end

    def regression_model_parameters(date)
      model = @models[model_type?(date)]
      [model.a, model.b, model.r2, model.base_temperature, model.key, heating_on?(date)]
    end

    def cusum_standard_deviation_average
      # puts "Currently configured model: #{self.class.name}"
      results = {}
      results_hash = {
        actual_kwh:    [],
        predicted_kwh: []
      }
      results[:all] = results_hash.deep_dup

      logger.info "Standard deviation calculation between #{@amr_data.start_date}  and #{@amr_data.end_date}"

      (@amr_data.start_date..@amr_data.end_date).each do |date|
        model_type = model_type?(date)
        results[model_type] = results_hash.deep_dup unless results.key?(model_type)

        predicted_kwh = predicted_kwh(date, @temperatures.average_temperature(date))
        actual_kwh = @amr_data.one_day_kwh(date)

        [model_type, :all].each do |type|
          results[type][:actual_kwh].push(actual_kwh)
          results[type][:predicted_kwh].push(predicted_kwh)
        end
      end

      new_results = results.deep_dup

      results.each do |type, values|
        diffs = [values[:actual_kwh], values[:predicted_kwh]].transpose.map {|x| x.reduce(:-)}
        new_results[type][:standard_deviation] = EnergySparks::Maths.standard_deviation(diffs).round(1).to_f
        new_results[type][:mean] = EnergySparks::Maths.mean(diffs).round(0).to_f
        new_results[type][:samples] = diffs.length
        new_results[type][:total_actual_kwh] = values[:actual_kwh].inject(:+).round(0)
        new_results[type][:total_predicted_kwh] = values[:predicted_kwh].inject(:+).round(0)
        new_results[type].delete(:actual_kwh)
        new_results[type].delete(:predicted_kwh)

        unless type == :all
          new_results[type][:a] = @models[type].a.round(0)
          new_results[type][:b] = @models[type].b.round(0)
          new_results[type][:r2] = @models[type].r2.round(3)
          new_results[type][:t0] = @models[type].base_temperature.round(1)
          new_results[type][:N] = @models[type].samples
          # pseudo aggregate r2 value
          new_results[:all][:r2] = 0.0 unless new_results[:all].key?(:r2) # inside loop for hash order
          new_results[:all][:r2] += @models[type].r2 * new_results[type][:total_actual_kwh]
        end
      end
      new_results[:all][:r2] /= new_results[:all][:total_actual_kwh] # pseudo value
      new_results[:all][:r2] = new_results[:all][:r2].round(4)

      new_results.each do |type, values|
        puts "#{format_cusum_results(type, values)}"
      end
      main = new_results[:all]
      [main[:standard_deviation], main[:mean], main[:total_actual_kwh], main[:total_predicted_kwh], new_results]
    end

    def format_cusum_results(type, results)
      sprintf('%26.26s: sd: %4.0f mean: %3.0f act: %8.0f pred: %8.0f x %4d', type, results[:standard_deviation],
        results[:mean], results[:total_actual_kwh], results[:total_predicted_kwh], results[:samples])
    end

    def save_raw_data_to_csv_for_debug(filename)
      header = ['Date', 'Month', 'DOY', 'Occupied', 'HeatingOn', 'AvgTemp', 'DegreeDays', 'MinHeatkWh',
                'ModelType', 'baseTemp', 'a', 'b', 'TotalkWh', 'PredictedkWh'] + Range.new(0, 47).to_a + Range.new(0, 47).to_a
      File.open(filename, 'w') do |file|
        file.puts header.join(',')
        (@amr_data.start_date..@amr_data.end_date).each do |date|
          one_days_data = @amr_data[date]
          line = []
          if one_days_data.nil?
            line.push(date)
            line.push('No AMR data for this date')
          else
            avg_temperature = @temperatures.average_temperature(date)
            model_type = model_type?(date)
            degree_days = @temperatures.degree_days(date, base_degreedays_temperature)
            line.push(
              date,
              date.strftime('%m'),
              date.strftime('%a'),
              occupied?(date),
              heating_on?(date),
              avg_temperature,
              degree_days,
              heating_day_minimum_kwh(date, avg_temperature),
              model_type,
              @models[model_type].base_temperature,
              @models[model_type].a,
              @models[model_type].b,
              one_days_data.one_day_kwh,
              predicted_kwh(date, avg_temperature)
            )
            line += one_days_data.kwh_data_x48
            line += @temperatures[date]
          end
          file.puts line.join(',')
        end
      end
    end
  end
end

# frozen_string_literal: true

class TargetMeter
  class TemperatureCompensatedDailyDayTypeBase < DailyDayType
    DEGREEDAY_BASE_TEMPERATURE = 15.5
    RECOMMENDED_HEATING_ON_TEMPERATURE = 14.5
    WITHIN_TEMPERATURE_RANGE = 3.0
    TARGET_TEMPERATURE_DAYS_EITHER_SIDE = 4

    def target_degreedays_average_in_date_range(d1, d2)
      d_days = 0.0
      (d1..d2).each do |date|
        d_days += target_degree_days(date)
      end
      d_days / (d2 - d1 + 1)
    end

    def self.format_missing_profiles(d)
      "Unable to find matching profile for on/at #{d[:target_day_type]} td: #{d[:target_date].strftime('%a %d %b %Y')} sd: #{d[:synthetic_date].strftime('%a %d %b %Y')} T = #{d[:target_temperature].round(1)} heating: #{d[:heating_on]}"
    end

    private

    def num_same_day_type_required(amr_data)
      # thermally massive model day of week dependent so
      # unlikely to be able to scan that far to find dates
      # within temperature range, so school day profiles
      # will be less smoothed
      {
        holiday: 4,
        weekend: 6,
        schoolday: local_heating_model(amr_data).thermally_massive? ? 4 : 10
      }
    end

    def temperatures
      meter_collection.temperatures
    end

    def holidays
      meter_collection.holidays
    end

    def average_profile_for_day_x48(target_date:, synthetic_amr_data:, synthetic_date:)
      compensation_temperature = target_temperature(target_date: target_date, synthetic_date: synthetic_date)

      profile = averaged_temperature_target_profile(synthetic_amr_data, synthetic_date, target_date,
                                                    compensation_temperature)

      profile[:profile_x48]
    end

    def target_temperature(target_date:, synthetic_date:)
      @target_temperature ||= {}
      @target_temperature[target_date] = calculate_target_temperature(synthetic_date, target_date)

      @target_degree_days ||= {}
      @target_degree_days[target_date] ||= [0.0, DEGREEDAY_BASE_TEMPERATURE - @target_temperature[target_date]].max

      @target_temperature[target_date]
    end

    def target_degree_days(date)
      @target_degree_days[date]
    end

    def calculate_target_temperature(synthetic_date, target_date)
      past_target = target_date <= target_dates.original_meter_end_date

      if past_target
        temperatures.average_temperature(target_date)
      else
        temperatures.average_temperature_for_time_of_year(time_of_year: TimeOfYear.to_toy(synthetic_date),
                                                          days_either_side: TARGET_TEMPERATURE_DAYS_EITHER_SIDE)
      end
    end

    # =========================================================================================
    # general functions both future and past target date

    def averaged_temperature_target_profile(synthetic_amr_data, synthetic_date, target_date, target_temperature)
      heating_on = should_heating_be_on?(synthetic_date, target_date, target_temperature, synthetic_amr_data)

      profiles_to_average = find_matching_profiles_with_retries(synthetic_date, target_date, target_temperature,
                                                                heating_on, synthetic_amr_data)

      @debug = false

      if profiles_to_average.empty?
        @feedback[:missing_profiles] ||= []
        target_day_type = holidays.day_type(target_date)
        error = { target_day_type: target_day_type, target_date: target_date, synthetic_date: synthetic_date,
                  target_temperature: target_temperature, heating: heating_on }
        @feedback[:missing_profiles].push(error)
        return {}
      end

      model = local_heating_model(synthetic_amr_data)

      predicated_kwh = model.predicted_kwh_for_future_date(heating_on, synthetic_date, target_temperature)

      {
        profile_x48: normalised_profile_to_predicted_kwh_x48(profiles_to_average, predicated_kwh),
        temperature: target_temperature,
        heating_on: heating_on
      }
    end

    def find_matching_profiles_with_retries(synthetic_date, target_date, target_temperature, heating_on, amr_data)
      [30, 90, 180, 360].each do |scan_distance|
        profiles = find_matching_profiles(synthetic_date, target_date, target_temperature, heating_on, amr_data,
                                          scan_distance)
        return profiles unless profiles.empty?
      end

      []
    end

    def find_matching_profiles(synthetic_date, target_date, target_temperature, heating_on, amr_data,
                               matching_day_types)
      profiles_to_average = {}

      target_day_type = holidays.day_type(target_date)
      max_profiles_required = num_same_day_type_required(amr_data)[target_day_type]

      scan_failures = []

      model = local_heating_model(amr_data)

      scan_dates = nearby_matching_days(synthetic_date, amr_data, target_day_type, matching_day_types)

      dates_with_matching_temperatures = scan_dates.select do |scan_date|
        synthetic_temperature = temperatures.average_temperature(scan_date)
        temperature_within_range?(synthetic_temperature, target_temperature, heating_on)
      end

      dates_with_heating_on_within_temperature_range = dates_with_matching_temperatures.select do |scan_date|
        model.heating_on?(scan_date) == heating_on
      end

      if dates_with_heating_on_within_temperature_range.empty?
        max_profiles_required = num_same_day_type_required(amr_data)[target_day_type]
        debug "Unable to find match for #{synthetic_date}: #{target_day_type} dist #{matching_day_types} matching days: #{scan_dates.length} temperature ok #{dates_with_matching_temperatures.length} heating #{heating_on ? 'on' : 'off'} 0"
        return []
      end

      dates_matching_model = dates_with_heating_on_within_temperature_range

      if target_day_type == :schoolday && model.thermally_massive?
        matches = dates_matching_model.select { |date| date.wday == target_date.wday }
        dates_matching_model = matches if matches.length >= max_profiles_required
      end

      profile_dates = dates_matching_model[0...max_profiles_required]

      if profile_dates.length < max_profiles_required
        debug "Shortage of profiles: for #{target_day_type} #{synthetic_date} dist #{matching_day_types} got #{dates_with_heating_on_within_temperature_range.length} need #{max_profiles_required} model match #{dates_matching_model.length}"
      end

      profile_dates.map { |profile_date| amr_data.one_days_data_x48(profile_date) }
    end

    def debug(var, ap: false)
      logger.info var
      return unless @debug && !Object.const_defined?('Rails')

      if ap
        ap var
      else
        puts var
      end
    end

    def nearby_matching_days(synthetic_date, amr_data, day_type, matching_days)
      future_dates = dates_to_scan(synthetic_date,  1, matching_days, amr_data, day_type)
      past_dates   = dates_to_scan(synthetic_date - 1, -1, matching_days, amr_data, day_type)

      # zip truncates to length of object being zipped
      if future_dates.length > past_dates.length
        future_dates.zip(past_dates).flatten.compact[0...matching_days]
      else
        past_dates.zip(future_dates).flatten.compact[0...matching_days]
      end
    end

    def dates_to_scan(synthetic_date, direction, dates_needed, amr_data, day_type)
      date_offset = 0
      dates = []
      while dates.length < dates_needed
        date = synthetic_date + date_offset
        date_offset += direction
        return dates unless date.between?(amr_data.start_date, amr_data.end_date)

        dates.push(date) if @meter_collection.holidays.day_type(date) == day_type
      end
      dates
    end

    def should_heating_be_on?(target_date, target_temperature, synthetic_amr_data)
      raise EnergySparksAbstractBaseClass, 'Call derived class!'
    end

    # don't temperature weight for the moment as for the majority, thermally
    # massive schools there are probably too few samples, and they may be biased
    # below or above the target temperature, in the shoulder seasons.
    #
    # - temperature compensated profiles are also tricky, as instead of increased
    #   kWh consumption per half hour, as assumed here (although within similar
    #   temperature range), more likely delivered by longer heating day i.e. wider profile
    #
    # - normalisation and temperature compensation in 1 function for performance as N (4-10) x 48 multiplications
    #
    def normalised_profile_to_predicted_kwh_x48(profiles_x48, predicated_kwh)
      normalised_profiles = profiles_x48.map do |profile_x48|
        days_kwh = profile_x48.sum
        if days_kwh == 0.0
          Array.new(48, 0.0)
        else
          profile_x48.map do |half_hour_kwh|
            half_hour_kwh / days_kwh
          end
        end
      end

      sum_normalised_profiles_x48 = AMRData.fast_add_multiple_x48_x_x48(normalised_profiles)

      AMRData.fast_multiply_x48_x_scalar(sum_normalised_profiles_x48, predicated_kwh / normalised_profiles.length)
    end

    def temperature_within_range?(temperature, range_temperature, heating_on)
      within_range = heating_on ? WITHIN_TEMPERATURE_RANGE : 2.0 * WITHIN_TEMPERATURE_RANGE
      temperature.between?(range_temperature - within_range, range_temperature + within_range)
    end

    # =========================================================================================
    # local heating model management
    #
    # for the moment define the modelling period as that of the most recent
    # 1 year period, of the original meter, plus synthetic data if the original
    # meter has less data, rather than just using the modelling before the target
    # date - this runs the risk the model significantly evolves over time adjusting the
    # original target but is balanced against the model improving with more real data and
    # less synthetic data as time progresses
    # - there is a general expectation the model should always run as the prior synthetic
    # - meter generation process of up to 1 year should ensure there is enough data with
    #   reasonable thermostatic characteristics
    def heating_model_period(amr_data)
      end_date = amr_data.end_date
      start_date = [end_date - 364, amr_data.start_date].max
      SchoolDatePeriod.new(:target_meter, '1 yr benchmark', start_date, end_date)
    end

    def local_heating_model(amr_data)
      @local_heating_model ||= calc_local_heating_model(amr_data)
    end

    def calc_local_heating_model(amr_data)
      # self(Meter).amr_data not set yet so create temporary meter for model
      meter_for_model = Dashboard::Meter.clone_meter_without_amr_data(self)
      meter_for_model.amr_data = amr_data

      model = meter_for_model.heating_model(heating_model_period(amr_data))
      debug = model.models.transform_values(&:to_s)
      debug.transform_keys! { |key| :"temperature_compensation_#{key}" }
      debug[:temperature_compensation_model] = model.class.name
      debug[:temperature_compensation_thermally_massive] = model.thermally_massive?
      debug[:temperature_compensation_non_heating_model] = model.non_heating_model.class.name
      debug[:temperature_compensation_non_heating_model_avgmax_kwh] =
        model.non_heating_model.average_max_non_heating_day_kwh
      debug.merge!(degree_day_debug)
      @feedback.merge!(debug)
      model
    end

    def degree_day_debug
      annual_degree_days = {}
      start_date = temperatures.end_date - 365

      while start_date >= temperatures.start_date
        end_date = start_date + 365
        dr = "Annual degree days: #{start_date.strftime('%b %Y')}/#{end_date.year}"
        dd = temperatures.degree_days_in_date_range(start_date, end_date, DEGREEDAY_BASE_TEMPERATURE)
        annual_degree_days[dr] = dd
        start_date -= 365
      end

      return {} if annual_degree_days.empty?

      average = annual_degree_days.values.sum / annual_degree_days.length

      annual_degree_days.transform_values { |dd| "#{dd.round(0)} dd: #{(100.0 * ((dd / average) - 1.0)).round(1)}%" }
    end
  end
end

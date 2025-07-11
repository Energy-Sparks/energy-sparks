# frozen_string_literal: true

# validates AMR data
# - checks for missing data
#   - if there is too big a gap it reduces the start and end dates for the amr data
#   - if there are smaller gaps it attempts to fill them in using nearby data
#     - electricity; tries to find nearest similar day
#     - gas; looks for a day where temperature was similar
#   - and if its heat/gas data then it adjusts for temperature
module Aggregation
  class ValidateAmrData
    class NotEnoughTemperaturedata < StandardError; end
    class UnexpectedGroupRule < StandardError; end

    include Logging

    FSTRDEF = '%a %d %b %Y' # fixed format for reporting dates for error messages
    MAXGASAVGTEMPDIFF = 5 # max average temperature difference over which to adjust temperatures
    MAXSEARCHRANGEFORCORRECTEDDATA = 100
    NO_MODEL = 0 # model calc failed

    attr_reader :data_problems, :meter_id

    def initialize(dashboard_meter, max_days_missing_data, holidays, temperatures)
      @meter = dashboard_meter
      @amr_data = dashboard_meter.amr_data
      @meter_id = dashboard_meter.mpan_mprn
      @holidays = holidays
      @temperatures = temperatures
      @max_days_missing_data = max_days_missing_data
      @bad_data = 0
      @run_date = Time.zone.today - 4 # TODO(PH,16Sep2019): needs rethink
      @data_problems = {}
    end

    def validate(debug_analysis: false)
      logger.debug '=' * 150
      logger.debug "Validating meter data of type #{@meter.meter_type} #{@meter.name} #{@meter.id}"
      logger.debug "Meter data from #{@meter.amr_data.start_date} to #{@meter.amr_data.end_date}"
      logger.debug "DCC Meter #{@meter.dcc_meter}"

      if debug_analysis
        assess_null_data # does nothing, count not used?
        Rails.logger.debug { "Before validation #{missing_data} missing items of data" }
      end

      do_validations

      # only summarise bad data in development
      if debug_analysis || logger.level >= Logger::INFO
        @amr_data.summarise_bad_data
        @amr_data.summarise_bad_data_stdout if debug?
      end
      if debug_analysis
        Rails.logger.debug { "After validation #{missing_data} missing items of data" }
        Rails.logger.debug missing_data_stats
        assess_null_data # does nothing, count not used?
      end
      logger.debug '=' * 150
    end

    private

    # Carry out a series of validations and corrections to the underlying meter data
    def do_validations
      # Removes data for today as it won't be complete
      # Also removes any spurious future dates
      remove_final_meter_reading_if_today

      # Raises exception if temperature data missing or doesn't cover entire range of
      # the gas meter data, prior to any corrections or adjustments
      check_temperature_data_covers_gas_meter_data_range

      # Extracts the :meter_corrections from the meter attributes and stores them
      # as meter_correction_rules, for later processing. If this is a gas meter,
      # and there are no other rules, then configures an :auto_insert_missing_readings
      # rule that will set weekend data to zero
      #
      # The corrections are applied in a later step
      process_meter_attributes

      # Meter readings from the DCC can include some known values for 'bad data'?
      # Remove these individual HH readings, or in some cases entire days of data
      # in which these values occur
      remove_dcc_bad_data_readings if @meter.dcc_meter

      remove_negative_readings if %i[electricity gas].include?(@meter.meter_type)

      # Adjusts amr data start/end by one day to ignore days with partial data
      # (This overlaps with the remove_final_meter_reading_if_today check done
      # in previous step)
      #
      # Then for any nil readings, we either interpolate between gaps in the day
      # or substitute the entire day if there are two many gaps
      correct_nil_readings

      # Apply all of the meter correction attributes configured for the meter
      # Note: @meter.meter_correction_rules will never be nil, as its initialised
      # to an empty array and can only be added to
      meter_corrections unless @meter.meter_correction_rules.nil?

      Corrections::OverrideNightToZero.apply(nil, nil, @meter) if @meter.meter_type == :solar_pv

      # Scans the amr data to look for gaps that are larger than @max_days_missing_data
      # If found, then AMR data start date will be moved to the final day of the gap.
      # Means that if there are any big holes in the data, it will be skipped.
      #
      # Ignores gaps which might be filled in the next step
      check_for_long_gaps_in_data

      # Tries to find substitute data for all missing days.
      # Uses different approaches for gas and electricity data.
      # e.g. gas substitutions looks for days with similar temperature
      fill_in_missing_data

      # Scans again for missing days, but just in holidays. Tries to substitute
      # with data from similar holiday in previous year. Again electricity and
      # gas substitutions are slightly different
      correct_holidays_with_adjacent_academic_years

      # One final pass to find missing days. In this case if found the day is
      # substituted with a fixed value of '0.0123456' for each HH reading and
      # a flag of 'PROB'
      # Why not zero?
      Corrections::FinalMissing.correct(@meter)
    end

    def debug? = false && [2_380_001_730_739].include?(@meter.mpxn.to_i)

    # Attempts to build a heating model from this meter's data. Model is used
    # to substitute missing gas data
    def heating_model
      @heating_model ||= create_heating_model
    end

    # Finds the meter corrections attributes, then copies them to the
    # meter_correction_rules for the meter. If there are no
    # rules and this is a gas meter, then it will automatically add a rule to set
    # any missing weekend data to zero
    #
    # Note: as these rules are only used by this class, the list of rules could
    # just be a member variable, rather than adding a method/data to Meter
    def process_meter_attributes
      meter_attributes_corrections = @meter.attributes(:meter_corrections)
      if meter_attributes_corrections.nil?
        auto_insert_for_gas_if_no_other_rules
      else
        @meter.insert_correction_rules_first(meter_attributes_corrections)
      end
    end

    def auto_insert_for_gas_if_no_other_rules
      return unless @meter.meter_type.to_sym == :gas

      logger.info "Adding auto insert missing readings as we're a gas meter & no other corrections"
      @meter.insert_correction_rules_first([{ auto_insert_missing_readings: { type: :weekends } }])
    end

    # Applies all the meter corrections configured in the meter attributes.
    # Relies on +process_meter_attributes+ having been called first to initialise
    # the list of corrections
    #
    # Rules are split into "grouped" rules (defined by +grouped_rule?+) and "single rules".
    # Single rules are applied first, then the remaining grouped rules.
    def meter_corrections
      return if @meter.meter_correction_rules.nil? # rules are never nil, but may be empty

      single_rules, grouped_rules = split_into_single_and_grouped_rules(@meter.meter_correction_rules)

      apply_single_rules(single_rules)

      apply_grouped_rules(grouped_rules)
    end

    def split_into_single_and_grouped_rules(rules)
      [
        rules.reject { |rule| grouped_rule?(rule) },
        rules.select { |rule| grouped_rule?(rule) }
      ]
    end

    def grouped_rule?(rule)
      rule.is_a?(Hash) &&
        !!%i[override_zero_days_electricity_readings].intersect?(rule.keys)
    end

    # Apply a list of meter corrections
    #
    # @param Array single_rules an array of meter corrections Hashes
    def apply_single_rules(single_rules)
      single_rules.each do |rule|
        apply_one_meter_correction(rule)
      end
    end

    def apply_grouped_rules(grouped_rules)
      rules_grouped_by_type = group_rules_by_type(grouped_rules)
      rules_grouped_by_type.each do |type, rules|
        case type
        when :override_zero_days_electricity_readings
          override_zero_days_electricity_readings_rules(rules)
        else
          raise UnexpectedGroupRule, "Unexpected rule type #{type}"
        end
      end
    end

    def group_rules_by_type(grouped_rules)
      groups = {}
      grouped_rules.each do |rule|
        rule.each do |type, config|
          groups[type] ||= []
          groups[type].push({ type => config })
        end
      end
      groups
    end

    # Interprets and then applies a single meter correction rule
    #
    # Rules are either a Symbol (true for a couple of corrections) or a Hash
    # The Hash structure provides parameters, e.g. start/end dates and other values
    # to customise the rule
    #
    # See the class definitions in MeterAttributes for structure definitions.
    # This class only interprets those in the +:meter_corrections+ category.
    #
    # Note: there's not currently any defined order in which rules will be applied.
    # This shouldn't typically be an issue but its possible that in some cases
    # we may do substitutions to then truncate data
    #
    # @param rule either a Symbol or a Hash
    def apply_one_meter_correction(rule)
      logger.debug '-' * 80
      logger.debug "Manually defined meter corrections: #{rule}"
      if rule.is_a?(Symbol) && rule == :set_all_missing_to_zero
        logger.debug 'Setting all missing data to zero'
        # set any missing days to have zero readings
        set_all_missing_data_to_zero
      elsif rule.is_a?(Symbol) && rule == :correct_zero_partial_data
        logger.debug 'Correcting partially missing (zero) data'
        # fix dates with missing readings (defined as 0.0), interpolating
        # missing values, unless there are too many in which case entire day
        # is substituted
        correct_zero_partial_data
      elsif rule.key?(:rescale_amr_data)
        # scale HH readings within a date range
        scale_amr_data(
          rule[:rescale_amr_data][:start_date],
          rule[:rescale_amr_data][:end_date],
          rule[:rescale_amr_data][:scale]
        )
      elsif rule.key?(:readings_start_date)
        # set meter start date
        apply_readings_start_date(rule[:readings_start_date])
      elsif rule.key?(:readings_end_date)
        # set meter end date
        apply_readings_end_date(rule[:readings_end_date])
      elsif rule.key?(:set_bad_data_to_zero)
        # overwrite existing data in a range to zero
        zero_data_in_date_range(
          rule[:set_bad_data_to_zero][:start_date],
          rule[:set_bad_data_to_zero][:end_date]
        )
      elsif rule.key?(:set_missing_data_to_zero)
        if rule[:set_missing_data_to_zero].nil?
          # set all missing days, up until yesterday to have zero readings
          zero_missing_data_in_date_range(nil, nil, true)
        else
          # set all missing days, within range to have zero readings
          zero_missing_data_in_date_range(
            rule[:set_missing_data_to_zero][:start_date],
            rule[:set_missing_data_to_zero][:end_date],
            rule[:set_missing_data_to_zero][:zero_up_until_yesterday]
          )
        end
      elsif rule.key?(:auto_insert_missing_readings)
        if (rule[:auto_insert_missing_readings].is_a?(Symbol) && # backwards compatibility
            rule[:auto_insert_missing_readings] == :weekends) ||
           rule[:auto_insert_missing_readings][:type] == :weekends
          # replace just the missing weekend data in the range to zero
          replace_missing_weekend_data_with_zero
        elsif rule[:auto_insert_missing_readings][:type] == :date_range
          # replace missing data in the range to zero
          replace_missing_data_with_zero(
            rule[:auto_insert_missing_readings][:start_date],
            rule[:auto_insert_missing_readings][:end_date]
          )
        else
          val = rule[:auto_insert_missing_readings]
          raise EnergySparksMeterSpecification, "unknown auto_insert_missing_readings meter attribute #{val}"
        end
      elsif rule.key?(:no_heating_in_summer_set_missing_to_zero)
        logger.debug 'Got missing summer rule'
        # Sets missing data to zero between the start/end time of year
        set_missing_data_to_zero_on_heating_meter_during_summer(
          rule[:no_heating_in_summer_set_missing_to_zero][:start_toy],
          rule[:no_heating_in_summer_set_missing_to_zero][:end_toy]
        )
      elsif rule.key?(:override_bad_readings)
        # Doesnt just fill in missing data, because the final override parameter is
        # set this will remove all existing readings within the specified range and
        # attempt to substitute them.
        fill_in_missing_data(
          rule[:override_bad_readings][:start_date],
          rule[:override_bad_readings][:end_date],
          'X',
          true
        )
      elsif rule.key?(:extend_meter_readings_for_substitution)
        # extend the meter date range, to force additional substitutions. That
        # might happen as part of processing additional rules, or the later
        # substitutions done in +do_validations+
        if rule[:extend_meter_readings_for_substitution].key?(:start_date)
          extend_start_date(rule[:extend_meter_readings_for_substitution][:start_date])
        end
        if rule[:extend_meter_readings_for_substitution].key?(:end_date)
          extend_end_date(rule[:extend_meter_readings_for_substitution][:end_date])
        end
      elsif rule.key?(:override_night_to_zero)
        Corrections::OverrideNightToZero.apply(rule.dig(:override_night_to_zero, :start_date),
                                               rule.dig(:override_night_to_zero, :end_date),
                                               @meter)
      end
    end

    # Forces the meter start date to the provided date
    #
    # Setting the start date on the AMR data will cause all previous readings to be
    # removed.
    #
    # Will throw an exception if the provided date isn't in the current meter date
    # range
    #
    # A status code is applied to the date to indicate why it is being used
    def apply_readings_start_date(fix_start_date)
      check_date_exists(fix_start_date, :readings_start_date)
      logger.debug "Fixing start date to #{fix_start_date} for #{@meter_id}"
      substitute_data_x48 = @amr_data.one_days_data_x48(fix_start_date)
      # Setting start date will truncate earlier data. Application will end up
      # storing the FIXS reading as the earliest reading. Prior data will be deleted
      @amr_data.add(fix_start_date,
                    OneDayAMRReading.new(meter_id, fix_start_date, 'FIXS', nil, DateTime.now, substitute_data_x48))
      @amr_data.set_start_date(fix_start_date)
    end

    # Forces the meter end date to the provided date
    #
    # Setting the end date on the AMR data will cause all subsequent readings to be
    # removed.
    #
    # Will throw an exception if the provided date isn't in the current meter date
    # range
    #
    # A status code is applied to the date to indicate why it is being used
    def apply_readings_end_date(fix_end_date)
      check_date_exists(fix_end_date, :readings_end_date)
      logger.debug "Fixing end date to #{fix_end_date}"
      substitute_data_x48 = @amr_data.one_days_data_x48(fix_end_date)
      # Setting end date will truncate earlier data. Application will end up
      # storing the FIXE reading as the latest reading. Later data will be deleted
      @amr_data.add(fix_end_date,
                    OneDayAMRReading.new(meter_id, fix_end_date, 'FIXE', nil, DateTime.now, substitute_data_x48))
      @amr_data.set_end_date(fix_end_date)
    end

    def check_date_exists(date, attribute)
      return if @amr_data.date_exists?(date)

      error_message = "Unable to apply #{attribute} correction for meter #{@meter_id}. There is no meter data for #{date}. Check the date and/or for missing readings"
      raise EnergySparksMeterSpecification, error_message
    end

    # Set the start date for the AMR data to the specified date
    #
    # No readings are added at this point, so relies on subsequent meter corrections/validation
    # behaviour to fill in the blanks
    def extend_start_date(date)
      logger.info "Extending start date to #{date}"
      @amr_data.set_start_date(date)
    end

    # Set the end date for the AMR data to the specified date
    #
    # No readings are added at this point, so relies on subsequent meter corrections/validation
    # behaviour to fill in the blanks
    def extend_end_date(date)
      logger.info "Extending end date to #{date}"
      @amr_data.set_end_date(date)
    end

    def set_all_missing_data_to_zero_by_time_of_year(start_toy, end_toy, type)
      year_count = {}
      end_date = [@amr_data.end_date, @run_date].max
      (@amr_data.start_date..end_date).each do |date|
        toy = TimeOfYear.new(date.month, date.day)
        next unless @amr_data.date_missing?(date) && toy >= start_toy && toy <= end_toy

        zero_data = Array.new(48, 0.0)
        data = OneDayAMRReading.new(meter_id, date, type, nil, DateTime.now, zero_data)
        @amr_data.add(date, data)

        year_count[date.year] = 0 unless year_count.key?(date.year)
        year_count[date.year] += 1
      end
      year_count.each do |year, count|
        logger.info "set during #{year} * #{count} to zero"
      end
    end

    def remove_dcc_bad_data_readings
      logger.info 'Checking dcc meter for bad values'
      too_much_bad_data = {}
      for_interpolation = {}
      ok_data = {}
      @amr_data.each_date_kwh do |date, days_kwh_x48|
        bad_value_count = days_kwh_x48.count { |kwh| bad_dcc_value?(kwh) }
        if bad_value_count > 7
          too_much_bad_data[date] = bad_value_count
        elsif bad_value_count.positive?
          for_interpolation[date] = bad_value_count
        else
          ok_data[date] = 0
        end
      end

      if too_much_bad_data.length.positive?
        logger.info 'The following dates have too much DCC bad data, so removing them for future whole day substitution'
        log_dates(too_much_bad_data)
        too_much_bad_data.each_key do |date|
          @amr_data.delete(date)
        end
      end

      if for_interpolation.length.positive?
        logger.info 'The following dates have bad half hour kWh value, so nullifying for future interpolation'
        log_dates(for_interpolation)
        for_interpolation.each_key do |date|
          days_kwh_x48 = @amr_data.days_kwh_x48(date)
          days_kwh_x48.map! { |kwh| bad_dcc_value?(kwh) ? nil : kwh }
          data = OneDayAMRReading.new(meter_id, date, 'DCCP', nil, DateTime.now, days_kwh_x48)
          @amr_data.add(date, data)
        end
      end

      logger.info "Leaving #{ok_data.length} days of dcc data with no bad values"
    end

    def remove_negative_readings
      @amr_data.each_date_kwh do |date, days_kwh_x48|
        x48_negative_nil = days_kwh_x48.map { |kwh| kwh&.negative? ? nil : kwh }
        if days_kwh_x48 != x48_negative_nil
          @amr_data.add(date, OneDayAMRReading.new(meter_id, date, 'RNEG', nil, DateTime.now, x48_negative_nil))
        end
      end
    end

    # typical problem for DCC provided data, has partial data for today from 4.00am batch
    def remove_final_meter_reading_if_today
      return unless @meter.amr_data.end_date >= Time.zone.today

      (Time.zone.today..@meter.amr_data.end_date).each do |date|
        # would assume, unless spurious future readings are provided that the code only loops once
        @amr_data.set_end_date(date - 1)
        logger.info "Removing final partial dcc meter reading for today #{date}"
      end
    end

    def log_dates(dates_hash)
      dates_hash.keys.each_slice(8) do |dates|
        logger.info dates.map { |d| d.strftime('%d-%b-%Y') }.join(' ')
      end
    end

    def bad_dcc_value?(kwh)
      BadValues.bad_dcc_value?(kwh, @meter.meter_type)
    end

    # A specific built in correction that will substitute any nil readings with
    # either interpolated values, or substitute entire days if there is too much
    # missing data
    #
    # Applies same correction rules regardless of meter type.
    def correct_nil_readings
      remove_missing_start_end_dates_if_partial_nil
      correct_zero_partial_data(missing_data_value: nil)
      # leave the rest of the validation to fix whole missing days
    end

    # Adjusts the end of the meter data range by up to one day, to exclude
    # a start or end day that has ANY missing half-hourly readings.
    #
    # Only checks for a single day at the start/end, so if the new range still
    # has missing readings then this might be further adjusted, e.g. by
    # interpolation or substitution.
    def remove_missing_start_end_dates_if_partial_nil
      if @amr_data.days_kwh_x48(@amr_data.start_date).any?(&:nil?)
        logger.info "Moving meter start date #{@amr_data.start_date} 1 day forward as only partial data on start date"
        @amr_data[@amr_data.start_date].set_type('PSTD')
        @amr_data.set_start_date(@amr_data.start_date + 1)
      end

      return unless @amr_data.days_kwh_x48(@amr_data.end_date).any?(&:nil?)

      logger.info "Moving meter end date #{@amr_data.end_date} one day back as only partial data on end date"
      @amr_data[@amr_data.end_date].set_type('PETD')
      @amr_data.set_end_date(@amr_data.end_date - 1)
    end

    # Finds days with missing readings, as defined by +missing_data_value+.
    #
    # If there are less than +max_missing_readings+ for a given day, then the missing
    # values are replaced by interpolation.
    #
    # If there are more missing readings, then the entire day is substituted. When
    # the entire day is substituted we just attempt to find a similar nearby day.
    # There's no special processing for gas data at this point.
    #
    # This is called with +missing_data_value+ of +nil+ to remove nil readings, as well
    # as default value of +0.0+ to apply corrections when data isn't expected to be
    # zero.
    #
    # the Frome/Somerset csv feed has a small amount of zero data in its electricity csv feeds
    # sometimes its just a few points, sometimes its a whole day (with BST/GMT offset issues!)
    def correct_zero_partial_data(max_missing_readings: 6, missing_data_value: 0.0)
      # do this is a particular order to avoid substitiing partial data
      # with partial data
      missing_dates = remove_readings_with_too_many_missing_partial_readings(max_missing_readings, missing_data_value)

      interpolate_partial_missing_data(max_missing_readings, missing_data_value)

      substitute_partial_missing_data_with_whole_day(missing_dates)
    end

    # Scans the AMR data to find days in which +missing_data_value+ occurs in the half-hourly
    # readings. If found and there are less than +max_missing_readings+ then the missing values
    # are replaced with interpolated values.
    #
    # @param Integer max_missing_readings the maximum number of missing readings before day is removed
    # @param Float missing_data_value the value to check for, or nil
    def interpolate_partial_missing_data(max_missing_readings, missing_data_value)
      @amr_data.each_date_kwh do |date, days_kwh_x48|
        num_zero_values = days_kwh_x48.count(missing_data_value)
        next unless num_zero_values.positive? && num_zero_values <= max_missing_readings

        type = if @amr_data[date].type == 'ORIG'
                 (@meter.dcc_meter ? 'DMP' : 'CMP') + num_zero_values.to_s
               else
                 @amr_data[date].type
               end
        days_kwh_x48 = interpolate_zero_readings(days_kwh_x48, missing_data_value: missing_data_value)
        updated_data = OneDayAMRReading.new(meter_id, date, type, nil, DateTime.now, days_kwh_x48)
        @amr_data.add(date, updated_data)
      end
    end

    def assess_null_data
      (@amr_data.start_date..@amr_data.end_date).sum do |date|
        @amr_data.date_missing?(date) ? 48 : @amr_data.days_kwh_x48(date).count(&:nil?)
      end
    end

    def missing_data_stats
      stats = Hash.new { |h, k| h[k] = 0 }
      (@amr_data.start_date..@amr_data.end_date).each do |date|
        stats[@amr_data.substitution_type(date)] += 1
      end
      stats
    end

    def missing_data
      (@amr_data.start_date..@amr_data.end_date).count { |date| @amr_data.date_missing?(date) }
    end

    # Takes an array of dates then attempts to create substitute date for that
    # data. If a substitute can be found, then this is used to replace the date in the
    # meter data
    #
    # Regardless of meter type, the substitution process used here is what is used for
    # electricity meters, i.e. it will replace the days with a nearby weekend, weekday or
    # holiday date.
    #
    # @param Array missing_dates an array of Dates to process
    def substitute_partial_missing_data_with_whole_day(missing_dates)
      missing_dates.each do |date, type|
        date, updated_one_day_reading = substitute_missing_electricity_data(date, 'S')
        if updated_one_day_reading.nil?
          logger.debug "Unable to override partial/missing data for #{@meter_id} on #{date}"
        else
          updated_one_day_reading.set_type(type == 'ORIG' ? 'CMPH' : type)
          @amr_data.add(date, updated_one_day_reading.deep_dup)
        end
      end
    end

    # Scans the AMR data to find any days that have +missing_data_value+ in the half-hourly
    # readings. If there are more than +missing_data_value+ the day will be removed
    #
    # Returns an array of any days that are removed.
    #
    # @param Integer max_missing_readings the maximum number of missing readings before day is removed
    # @param Float missing_data_value the value to check for, or nil
    # @return Array a list of the removed days
    def remove_readings_with_too_many_missing_partial_readings(max_missing_readings, missing_data_value)
      @amr_data.each_date_kwh.filter_map do |date, days_kwh_x48|
        [date, @amr_data[date].type] if days_kwh_x48.count(missing_data_value) > max_missing_readings
      end
    end

    # Interpolate over missing readings (identified by +missing_data_value+)
    #
    # Interpolation is done by the Interpolate gem
    #
    # @param Array days_kwh_x48 an array of x48 half hourly readings
    # @param Float missing_data_value the float value or nil that identifies a missing reading
    # @returns Array a new array that consists of original readings plus interpolated values for missing readings
    def interpolate_zero_readings(days_kwh_x48, missing_data_value: 0.0)
      interpolation_data = {}

      days_kwh_x48.each_index do |halfhour_index|
        if days_kwh_x48[halfhour_index] != missing_data_value
          interpolation_data[halfhour_index] =
            days_kwh_x48[halfhour_index]
        end
      end

      interpolation = Interpolate::Points.new(interpolation_data)

      days_kwh_x48.each_index do |halfhour_index|
        if days_kwh_x48[halfhour_index] == missing_data_value
          days_kwh_x48[halfhour_index] =
            interpolation.at(halfhour_index)
        end
      end

      days_kwh_x48
    end

    # Find all missing days of data between two "times of year" and set their readings to zero
    #
    # A "time of year" is a hash with a +:month+ and a +:day_of_month+ value.
    #
    # Essentially defines a repeating rule that will be applied to all years of data,
    # setting readings to zero within the date range defined by the start and end values
    #
    # Method name indicates this is normally used to set heat meter data to zero in summer,
    # but there's nothing specific about the meter type or date range in the substitution
    # that is done.
    def set_missing_data_to_zero_on_heating_meter_during_summer(start_toy, end_toy)
      logger.info "Setting missing data to zero between #{start_toy} and #{end_toy}"
      set_all_missing_data_to_zero_by_time_of_year(start_toy, end_toy, 'SUMZ')
    end

    # Find all missing days of data and set their readings to zero
    def set_all_missing_data_to_zero
      logger.info 'Setting all missing data to zero'
      start_toy = TimeOfYear.new(1, 1) # 1st Jan
      end_toy = TimeOfYear.new(12, 31) # 31st Dec
      set_all_missing_data_to_zero_by_time_of_year(start_toy, end_toy, 'ALLZ')
    end

    # Scales all readings within a date range by a fixed value
    #
    # Typically used to correct where imperial to metric meter readings aren't
    # corrected to kWh properly at source
    def scale_amr_data(start_date, end_date, scale)
      logger.info "Rescaling data between #{start_date} and #{end_date} by #{scale}"
      rescaler = Corrections::Rescaler.new(@amr_data, @meter_id)
      @amr_data = rescaler.perform(start_date: start_date, end_date: end_date, scale: scale)
    end

    def correct_holidays_with_adjacent_academic_years
      missing_holiday_dates = []
      (@amr_data.start_date..@amr_data.end_date).each do |date|
        missing_holiday_dates.push(date) if @amr_data.date_missing?(date) && @holidays.holiday?(date)
      end

      missing_holiday_dates.each do |date| # rubocop:todo Metrics/BlockLength
        holiday_type = @holidays.type(date)

        matching_holidays = list_of_similar_holidays(date, holiday_type)
        if matching_holidays.empty?
          logger.info "Unable to find substitute matching holiday for date #{date}"
        else
          adjusted_date = find_matching_holiday_day(@amr_data, matching_holidays, date.wday)

          if adjusted_date.nil?
            zero_kwh_readings = Array.new(48, 0.0)
            type = @meter.meter_type == @gas ? 'G0H1' : 'E0H1'
            zero_gas_holiday_data = OneDayAMRReading.new(meter_id, date, type, adjusted_date, DateTime.now,
                                                         zero_kwh_readings)
            @amr_data.add(date, zero_gas_holiday_data) # have to assume if no replacement holiday reading gas was completely off
          elsif @meter.meter_type == :electricity
            logger.debug "Correcting missing electricity holiday on #{date} with data from #{adjusted_date}"
            substituted_electricity_holiday_data = OneDayAMRReading.new(meter_id, date, 'ESBH', adjusted_date,
                                                                        DateTime.now, @amr_data[adjusted_date].kwh_data_x48)
            @amr_data.add(date, substituted_electricity_holiday_data)
          elsif @meter.meter_type == :gas
            # perhaps would be better if substitute similar weekday had matching temperatures?
            # probably better this way if thermally massive building?
            if heating_model == NO_MODEL
              raise EnergySparksNotEnoughDataException,
                    "Failed to calculate model unable to substitute holiday day #{date} #{@meter_id}"
            end

            substitute_gas_data = adjusted_substitute_heating_kwh(date, adjusted_date)
            substituted_gas_holiday_data = OneDayAMRReading.new(meter_id, date, 'GSBH', adjusted_date, DateTime.now,
                                                                substitute_gas_data)
            @amr_data.add(date, substituted_gas_holiday_data)
          end
        end
      rescue EnergySparksUnexpectedStateException => e
        logger.error "Comment: deliberately rescued missing holiday data exception for date #{date}"
        logger.error e.message
      end
    end

    def find_matching_holiday_day(amr_data, list_of_holidays, day_of_week)
      list_of_holidays.each do |holiday_period|
        (holiday_period.start_date..holiday_period.end_date).each do |date|
          return date if date.wday == day_of_week && amr_data.date_exists?(date)
        end
      end
      nil
    end

    def list_of_similar_holidays(date, holiday_type)
      list_of_matching_holidays = []
      (1..3).each do |year_offset|
        hol = similar_holiday(date, holiday_type, year_offset) # forward N years
        list_of_matching_holidays.push(hol) unless hol.nil?
        hol = similar_holiday(date, holiday_type, -1 * year_offset) # back N years
        list_of_matching_holidays.push(hol) unless hol.nil?
      end
      list_of_matching_holidays
    end

    def similar_holiday(date, holiday_type, year_offset)
      return if holiday_type.nil?

      nth_academic_year = @holidays.nth_academic_year_from_date(year_offset, date, false)
      return nil if nth_academic_year.nil?

      hols = @holidays.find_holiday_in_academic_year(nth_academic_year, holiday_type)
      return hols unless hols.nil?

      logger.warn "Unable to find holiday of type #{holiday_type} and date #{date}  and offset #{year_offset}"
      nil
    end

    # Replace any missing weekend dates with zero data
    def replace_missing_weekend_data_with_zero
      (@amr_data.start_date..@amr_data.end_date).each do |date|
        next unless DateTimeHelper.weekend?(date) && @amr_data.date_missing?(date)

        zero_data = Array.new(48, 0.0)
        missing_weekend_data = OneDayAMRReading.new(meter_id, date, 'MWKE', nil, DateTime.now, zero_data)
        @amr_data.add(date, missing_weekend_data)
      end
    end

    # Replace missing days within date range to zero
    #
    # Note: Other than the status code used, this does the same as +zero_missing_data_in_date_range+
    #
    # @param Date start_date set to +nil+ to use meter start date
    # @param Date end_date set to +nil+ to use meter end date
    def replace_missing_data_with_zero(start_date, end_date)
      logger.info "Replacing missing data between #{start_date} and #{end_date} with zero"
      start_date = @amr_data.start_date if start_date.nil?
      end_date = @amr_data.end_date if end_date.nil?
      (start_date..end_date).each do |date|
        next unless @amr_data.date_missing?(date)

        zero_data = Array.new(48, 0.0)
        missing_data_zero_in_date_range = OneDayAMRReading.new(meter_id, date, 'MDTZ', nil, DateTime.now, zero_data)
        @amr_data.add(date, missing_data_zero_in_date_range)
      end
    end

    # Sets all data within the specified date range to zero. Only sets existing data
    # to zero, will not fill in any missing data
    def zero_data_in_date_range(start_date, end_date)
      logger.info "Overwriting bad data between #{start_date} and #{end_date} with zero"
      (start_date..end_date).each do |date|
        next unless @amr_data.date_exists?(date)

        zero_data = Array.new(48, 0.0)
        zero_data_day = OneDayAMRReading.new(meter_id, date, 'ZDTR', nil, DateTime.now, zero_data)
        @amr_data.add(date, zero_data_day)
      end
    end

    # Sets all missing data within a range to zero
    #
    # If the +zero_up_until_yesterday+ parameter is provided without an end date,
    # then this will populate readings up until yesterday, not the meter end date
    #
    # @param Date sd the start date, or nil to use the meter start date
    # @param Date ed the end date, or nil to use meter end date
    # @param boolean zero_up_until_yesterday if ed not provided then use yesterday as end
    def zero_missing_data_in_date_range(start_date, end_date, zero_up_until_yesterday)
      start_date = default_start_date(start_date)
      end_date   = default_end_date(end_date, zero_up_until_yesterday)

      logger.info "Setting missing data between #{start_date} and #{end_date} to zero"
      (start_date..end_date).each do |date|
        next unless @amr_data.date_missing?(date)

        zero_data = Array.new(48, 0.0)
        zero_data_day = OneDayAMRReading.new(meter_id, date, 'ZMDR', nil, DateTime.now, zero_data)
        @amr_data.add(date, zero_data_day)
      end
    end

    def default_start_date(sd_attribute)
      sd_attribute || @amr_data.start_date
    end

    def default_end_date(ed_attribute, zero_up_until_yesterday)
      if zero_up_until_yesterday
        ed_attribute || (Time.zone.today - 1)
      else
        ed_attribute || @amr_data.end_date
      end
    end

    def override_with_sheffield_solar_pv_data(start_date, end_date)
      if @meter.meter_type != :solar_pv
        raise EnergySparksMeterSpecification,
              "Unable to correct pv data, wrong meter type #{@meter.meter_type}"
      end

      sd = [start_date, @meter.amr_data.start_date].max
      ed = [end_date,   @meter.amr_data.end_date].min
      existing_kwh = sd <= ed ? @meter.amr_data.kwh_date_range(sd, ed) : 0.0
      logger.info "Correcting solar pv production data using Sheffield #{start_date} to #{end_date} current total kwh #{existing_kwh}"
      pv = SolarPvPanels.new(@meter.attributes(:solar_pv), @meter.meter_collection.solar_pv)
      (start_date..end_date).each do |date|
        pv_days_readings = pv.days_pv(date, @meter.solar_pv)
        @amr_data.add(date, pv_days_readings)
      end
      updated_kwh = @meter.amr_data.kwh_date_range(start_date, end_date)
      logger.info "Updated sheffield pv data kwh = #{updated_kwh}"
    end

    def in_meter_correction_period?(date)
      @meter.meter_correction_rules.each do |rule|
        next unless rule.is_a?(Hash) && rule.key?(:auto_insert_missing_readings) &&
                    rule[:auto_insert_missing_readings][:type] == :date_range
        if date.between?(rule[:auto_insert_missing_readings][:start_date],
                         rule[:auto_insert_missing_readings][:end_date])
          return true
        end
      end
      false
    end

    # Scans the AMR data to find gaps. If any large gaps are found then the
    # meter date range is adjusted so that it starts at the end of the gap.
    #
    # A maximum size of the gap is defined by +@max_days_missing_data+ which
    # is +AggregateDataService::MAX_DAYS_MISSING_DATA+ (50) by default.
    #
    # Iterates backwards through the date range so that if there's a recent
    # gap then we avoid iterating over the full range.
    def check_for_long_gaps_in_data
      gap_count = 0
      first_bad_date = Date.new(2050, 1, 1)
      (@amr_data.start_date..@amr_data.end_date).reverse_each do |date|
        if @amr_data.date_missing?(date)
          first_bad_date = date if gap_count.zero?
          gap_count += 1
        else
          gap_count = 0
        end
        next unless gap_count > @max_days_missing_data && !in_meter_correction_period?(date)

        min_date = first_bad_date + 1
        # Setting start date will truncate earlier data. Application will end up
        # storing the LGAP reading as the earliest reading. Prior data will be deleted
        @amr_data.set_start_date(min_date)
        msg =  "Ignoring all data before #{min_date.strftime(FSTRDEF)}"
        msg += " as gap of more than #{@max_days_missing_data} days "
        msg += "#{@amr_data.keys.index(min_date) - 1} days of data ignored"
        logger.info msg
        substitute_data = Array.new(48, 0.0)
        @amr_data.add(min_date, OneDayAMRReading.new(meter_id, min_date, 'LGAP', nil, DateTime.now, substitute_data))
        break
      end
    end

    def fill_in_missing_data(start_date = @amr_data.start_date, end_date = @amr_data.end_date, sub_type_code = 'S',
                             override = false)
      @amr_data.delete_date_range(start_date, end_date) if override
      missing_days = {}
      (start_date..end_date).each do |date|
        if @amr_data.date_missing?(date)
          if @meter.meter_type == :electricity
            missing_days[date] = substitute_missing_electricity_data(date, sub_type_code)
          elsif @meter.meter_type == :gas
            missing_days[date] = substitute_missing_gas_data(date, sub_type_code)
          end
        end
      end

      missing_days.each do |date, corrected_data|
        unless corrected_data.nil?
          _substitute_date, substitute_data = corrected_data
          @amr_data.add(date, substitute_data) unless substitute_data.nil? # TODO(PH) - handle nil? test by correction
        end
      end
    end

    # Substitute data for a given date
    #
    # If there are solar panels for the meter, and the date is after they were installed,
    # then it first attempts to substitute the day with a day of the same type (e.g. weekend, weekday)
    # and where the solar PV generation was similar.
    #
    # If no solar, or no similar day can be found then falls back to just finding
    # a similar day
    #
    # This is potentially called for more than just electricity meters, so method
    # name is a bit misleading.
    def substitute_missing_electricity_data(date, sub_type_code)
      if @meter.solar_pv_panels? && date >= @meter.first_solar_pv_panel_installation_date
        date, subbed_reading = substitute_missing_solar_mains_meter_data(date, sub_type_code, 's')
        if subbed_reading.nil?
          substitute_missing_data(date, sub_type_code, 'E')
        else
          [date, subbed_reading]
        end
      else
        substitute_missing_data(date, sub_type_code, 'E')
      end
    end

    # iterate out from missing data date, looking for a similar day without missing data
    def substitute_missing_data(date, sub_type_code, fuel_code)
      daytype(date)
      alternating_search_days_offset.each do |days_offset|
        substitute_date = date + days_offset
        if original_matching_substitute_date?(date, substitute_date)
          return [date, create_substituted_data(date, substitute_date, sub_type_code, fuel_code)]
        end
      end
      [date, nil]
    end

    # makes several attempts to find a day with similar solar pv, with gradually greater tolerance
    def substitute_missing_solar_mains_meter_data(date, sub_type_code, fuel_code)
      [[15, 0.1], [25, 0.15], [40, 0.25]].each do |days_search, criteria|
        date, sub = similar_solar_pv_day(date, sub_type_code, fuel_code, days_search, criteria)
        return [date, sub] unless sub.nil?
      end

      [date, nil]
    end

    def similar_solar_pv_day(date, sub_type_code, fuel_code, days_range, similar_pv_criteria)
      daytype(date)
      alternating_search_days_offset(days_range).each do |days_offset|
        substitute_date = date + days_offset
        unless @amr_data.date_exists?(substitute_date) || substitute_date < @meter.first_solar_pv_panel_installation_date
          next
        end

        if original_matching_substitute_date?(date,
                                              substitute_date) && similar_solar_pv_day?(date, substitute_date,
                                                                                        similar_pv_criteria)
          return [date, create_substituted_data(date, substitute_date, sub_type_code, fuel_code)]
        end
      end

      [date, nil]
    end

    def similar_solar_pv_day?(date1, date2, criteria)
      pv1 = @meter.solar_pv.one_day_total(date1)
      pv2 = @meter.solar_pv.one_day_total(date2)
      ((pv1 - pv2) / pv2).magnitude < criteria
    end

    def original_matching_substitute_date?(date, substitute_date)
      @amr_data.date_exists?(substitute_date) &&
        daytype(substitute_date) == daytype(date) &&
        @amr_data.substitution_type(substitute_date) == 'ORIG'
    end

    #
    #
    # :override_zero_days_electricity_readings => [
    #  {
    #   start_date: => # optional, default to 1st meter reading
    #   end_date: => # optional, default to last meter reading
    #   override: => true || false # option, defaults to true, false available to turn off e.g. could set to true for all Bath schools, except 1 meter at Twerton
    #   }
    #  ]
    def override_zero_days_electricity_readings_rules(rules)
      Rails.logger.debug rules if debug?

      rule_dates = rule_override_dates(rules, :override_zero_days_electricity_readings)

      zero_dates = identify_zero_or_partially_reading_days(rule_dates)

      override_zero_days_electricity_readings(zero_dates)
    end

    # Process a set of rules to attempt to resolve overlaps in date range and
    # allow one rule to override another.
    #
    # Note: this doesnt seem to be fully used/implemented. Relies on meter attribute
    # rules having a :default attribute which is not configured so can't be entered
    # via the front-end, although it is mentioned in the documentation. So all
    # rules are non_defaults?
    #
    # Rule precedence also makes assumptions about how data is provided by application
    #
    # Currently probably only safe to use non-overlapping, or completely overlapping
    # rules
    #
    # Returns a set of dates with rule on how they should be processed
    def rule_override_dates(rules, rule_type)
      matching_rules_arr_to_hash = rules.select { |r| r.key?(rule_type) }
      matching_rules = default_rules(matching_rules_arr_to_hash.pluck(rule_type))

      defaults     = matching_rules.select { |r| r[:default] == true }
      non_defaults = matching_rules.reject { |r| r[:default] == true }

      all_rules = [defaults, non_defaults].flatten # ensures default appear first

      resolve_rule_override_dates(all_rules)
    end

    def override_rule?(val)
      [true, :on, :intelligent_solar].include?(val)
    end

    def summarise_date_ranges(dates)
      drs = dates.slice_when do |prev, curr|
        prev + 1 != curr
      end

      drs.map { |ds| ds.first..ds.last }
    end

    def resolve_rule_override_dates(rules)
      dates = {}

      # assumes meter attributes appear in defined order from front end (false assumption?)
      rules.each do |rule|
        if override_rule?(rule[:override])
          (rule[:start_date]..rule[:end_date]).each do |date|
            dates[date] = rule[:override]
          end
        else
          dates.delete_if { |d, _override| d.between?(rule[:start_date], rule[:end_date]) }
        end
      end

      dates
    end

    def default_rules(rules, override_field: :override)
      rules.map { |r| default_rule(r, override_field) }
    end

    def default_rule(rule, override_field)
      if rule.nil?
        {
          start_date: @amr_data.start_date,
          end_date: @amr_data.end_date,
          override: true
        }
      else
        {
          start_date: rule[:start_date] || @amr_data.start_date,
          end_date: rule[:end_date] || @amr_data.end_date,
          override: rule[override_field].nil? || rule[override_field]
        }
      end
    end

    # Processes a list of dates to substitute the readings.
    #
    # Regardless of meter type, the substitution process used here is what is used for
    # electricity meters, i.e. it will replace the days with a nearby weekend, weekday or
    # holiday date.
    #
    # The symbol associated with each date is used to provide a status code that indicates
    # why the date was substituted (e.g. because of partial nils, or zeroes for whole day)
    #
    # @param Hash zero_days hash of Date => Symbol (:all, :partial)
    def override_zero_days_electricity_readings(zero_days)
      zero_days.each_key do |date|
        @amr_data.delete(date)
      end

      substituted_days = zero_days.to_h do |date, override_type|
        substitute_missing_electricity_data(date, override_type == :all ? 'Z' : 'z')
      end

      substituted_days.each do |date, one_days_data|
        @amr_data.add(date, one_days_data)
      end
    end

    # Queries the AMR data for existing dates that either contain all zero readings,
    # or depending on the rule, if there are sufficient zero readings during the night
    #
    # @param Hash dates a hash of Date => override (true, :on, :intelligent_solar)
    # @returns a Hash of Date => Symbol (:all, :partial)
    def identify_zero_or_partially_reading_days(dates)
      dates.filter_map do |date, override|
        if @amr_data.date_exists?(date) && @amr_data.one_days_data_x48(date).all?(&:zero?)
          [date, :all]
        elsif override == :intelligent_solar && @meter.solar_pv_panels? && has_zero_readings_at_night?(date)
          [date, :partial]
        end
      end.to_h
    end

    # Returns true if more than 10% of the half hourly readings in the night are less than 20 watts
    def has_zero_readings_at_night?(date, margin_watts = 20)
      kw_margin = margin_watts / 1000.0
      night_half_hours = Utilities::SunTimes.nighttime_half_hours(date, @meter.meter_collection)

      zero_night_readings = night_half_hours.map.with_index do |_night, hh_i|
        @amr_data.date_exists?(date) &&
          night_half_hours[hh_i] &&
          @amr_data.kwh(date, hh_i) < (kw_margin / 2.0) # v. kWh per half hour
      end

      zero_night_readings_count = zero_night_readings.count(true)

      percent_zero_night_readings = zero_night_readings_count.to_f / night_half_hours.length

      percent_zero_night_readings > 0.1 # more than 10% zero
    end

    # [1, -1, 2, -2 etc.]
    def alternating_search_days_offset(max_days = MAXSEARCHRANGEFORCORRECTEDDATA)
      @alternating_search_days_offset ||= {}
      @alternating_search_days_offset[max_days] ||= (1..max_days).to_a.zip((-max_days..-1).to_a.reverse).flatten
    end

    def substitute_missing_gas_data(date, sub_type_code)
      heating_on = heating_model.heat_on_missing_data?(date) if heating_model != NO_MODEL
      missing_daytype = daytype(date)
      avg_temperature = average_temperature(date)

      alternating_search_days_offset.each do |days_offset|
        substitute_date = date + days_offset
        next unless @amr_data.date_exists?(substitute_date)

        substitute_day_temperature = average_temperature(substitute_date)
        if heating_model == NO_MODEL
          if original_matching_substitute_date?(date, substitute_date)
            return [date, create_substituted_data(date, substitute_date, sub_type_code, 'G')]
          end
        elsif heating_on == heating_model.heat_on_missing_data?(substitute_date) &&
              within_temperature_range?(avg_temperature, substitute_day_temperature) &&
              daytype(substitute_date) == missing_daytype
          return [date, create_substituted_gas_data(date, substitute_date, sub_type_code)]
        end
      end
      logger.debug "Error: Unable to find suitable substitute for missing day of gas data #{date} temperature #{avg_temperature.round(0)} daytype #{missing_daytype} heating? #{heating_on}"
      [date, nil]
    end

    def create_substituted_gas_data(date, adjusted_date, sub_type_code)
      amr_day_type = day_type_to_amr_type_letter(daytype(date))
      sub_type = "G#{sub_type_code}#{amr_day_type}1"
      adjusted_data = adjusted_substitute_heating_kwh(date, adjusted_date)
      OneDayAMRReading.new(meter_id, date, sub_type, adjusted_date, DateTime.now, adjusted_data)
    end

    def create_substituted_data(date, adjusted_date, sub_type_code, fuel_code)
      amr_day_type = day_type_to_amr_type_letter(daytype(date))
      sub_type = "#{fuel_code}#{sub_type_code}#{amr_day_type}1"
      substitute_data = @amr_data.days_kwh_x48(adjusted_date).deep_dup
      OneDayAMRReading.new(meter_id, date, sub_type, adjusted_date, DateTime.now, substitute_data)
    end

    def average_temperature(date)
      @average_temperatures ||= {}
      begin
        @average_temperatures[date] ||= @temperatures.average_temperature(date)
      rescue StandardError => _e
        logger.error "Warning: problem generating missing gas data, as no temperature data for #{date}"
        raise
      end
    end

    def within_temperature_range?(day_temp, substitute_temp)
      criteria = MAXGASAVGTEMPDIFF * (day_temp < 20.0 ? 1.0 : 1.5) # relax criteria in summer
      (day_temp - substitute_temp).magnitude < criteria
    end

    def adjusted_substitute_heating_kwh(missing_day, substitute_day)
      kwh_prediction_for_missing_day = heating_model.predicted_kwh(missing_day,
                                                                   @temperatures.average_temperature(missing_day), substitute_day)
      kwh_prediction_for_substitute_day = heating_model.predicted_kwh(substitute_day,
                                                                      @temperatures.average_temperature(substitute_day))

      # using an adjustment of kWhs * (A + BTm)/(A + BTs), an alternative could be kWhs + B(Tm - Ts)
      prediction_ratio = kwh_prediction_for_missing_day / kwh_prediction_for_substitute_day
      if prediction_ratio.negative?
        logger.debug "Warning: negative predicated data for missing day #{missing_day} from #{substitute_day} setting to zero"
        prediction_ratio = 0.0
      end

      if kwh_prediction_for_substitute_day == 0.0
        logger.warn "Warning: zero predicted kwh for substitute day #{substitute_day} setting prediction_ratio to 0.0 for #{missing_day}"
        prediction_ratio = 1.0
      end

      prediction_ratio = 1.0 if kwh_prediction_for_substitute_day == 0.0 && kwh_prediction_for_missing_day == 0.0

      substitute_data = Array.new(48, 0.0)
      (0..47).each do |halfhour_index|
        substitute_data[halfhour_index] = @amr_data.kwh(substitute_day, halfhour_index) * prediction_ratio
      end
      substitute_data
    end

    def create_heating_model
      @model_cache = AnalyseHeatingAndHotWater::ModelCache.new(@meter)
      period_of_all_meter_readings = SchoolDatePeriod.new(:validation, 'Validation Period', @amr_data.start_date,
                                                          @amr_data.end_date)
      @model_cache.create_and_fit_model(:best, period_of_all_meter_readings, true)
    rescue EnergySparksNotEnoughDataException => e
      logger.info "Unable to calculate model data for heat day substitution for #{@meter_id}"
      logger.info e.message
      logger.info 'using simplistic substitution without modelling'
      NO_MODEL
    end

    def daytype(date)
      if @holidays.holiday?(date)
        weekend?(date) ? :holidayandweekend : :holidayweekday
      else
        weekend?(date) ? :weekend : :weekday
      end
    end

    def day_type_to_amr_type_letter(daytype)
      case daytype
      when :holidayandweekend
        'h'
      when :holidayweekday
        'H'
      when :weekend
        'W'
      when :weekday
        'S'
      else
        raise EnergySparksUnexpectedStateException, 'Unexpected day type'
      end
    end

    def weekend?(date)
      date.sunday? || date.saturday?
    end

    def no_readings?
      @amr_data.nil? || @amr_data.days.zero?
    end

    def check_temperature_data_covers_gas_meter_data_range
      return if @meter.fuel_type != :gas # no storage_heater as they are created later by the aggregation service
      return if no_readings?

      if @temperatures.blank?
        raise NotEnoughTemperaturedata,
              "Nil or empty temperature data for meter #{@meter.mpxn} #{@meter.fuel_type}"
      end

      return unless @temperatures.start_date > @amr_data.start_date || @temperatures.end_date < @amr_data.end_date

      raise NotEnoughTemperaturedata,
            "Temperature data from #{@temperatures.start_date} to #{@temperatures.end_date} doesnt cover period of #{@meter.mpxn} #{@meter.fuel_type} meter data from #{@amr_data.start_date} to #{@amr_data.end_date}"
    end
  end
end

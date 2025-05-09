# frozen_string_literal: true

module Usage
  class HolidayUsageCalculationService
    def initialize(analytics_meter, holidays, asof_date = Date.today)
      @meter = analytics_meter
      @holidays = holidays
      @asof_date = asof_date
    end

    # Returns the usage for a specific holiday, expressed as a
    # Holiday or School Period.
    #
    # Will return +nil+ if the meter doesn't have data for the
    # entire period
    #
    # @param [Holiday] school period, the period to be analysed
    # @return [CombinedUsageMetric] the calculated usage
    def holiday_usage(school_period:)
      return nil unless has_data_for_period?(school_period)

      CombinedUsageMetric.new(
        kwh: usage_for_period(school_period, :kwh),
        £: usage_for_period(school_period, :£),
        co2: usage_for_period(school_period, :co2)
      )
    end

    # Calculates the usage for the provided holiday period and
    # the same holiday period in the previous year. E.g. usage
    # Xmas 2022 holiday and the Xmas 2021 holiday.
    #
    # Does not do any temperature compensation or normalisation
    # of the usage across periods, so this is not consistent with
    # the alerts. So should only be used for reporting the "metered"
    # usage for the periods.
    #
    # @param [Holiday] school period, the period to be analysed
    # @return [OpenStruct]
    def holiday_usage_comparison(school_period:)
      usage_for_period = holiday_usage(school_period: school_period)
      previous_period = holiday_period_for_previous_year(school_period)
      usage_for_previous_period = previous_period.nil? ? nil : holiday_usage(school_period: previous_period)
      OpenStruct.new(
        usage: usage_for_period,
        previous_holiday_usage: usage_for_previous_period,
        previous_holiday: previous_period
      )
    end

    # For a given set of Holiday periods, returns the usage for that period
    # and the same period for the previous year where data is available
    #
    # Equivalent to calling +holiday_usage_comparison+ for each item in the
    # Array. Useful when tabulating usage across a range of periods
    #
    # @param [Array] school_periods, an array of periods
    # @return [Hash] of school_period => OpenStruct
    def holidays_usage_comparison(school_periods: [])
      school_periods.map do |school_period|
        [school_period, holiday_usage_comparison(school_period: school_period)]
      end.to_h
    end

    # Returns the usage for a full "calendar" of holidays periods
    #
    # A school has 6 holidays in a given year:
    # - Autumn half term
    # - Christmas holiday
    # - Spring half term
    # - Easter holiday
    # - Summer half-term
    # - Summer holiday
    #
    # The results will include all holidays from the current academic year
    # so far, plus those from the previous academic year that have not yet
    # happened.
    #
    # E.g. In March 2023 it would return the Autum half term, xmas holiday and
    # spring half term for the 2022/2023 calendar year. Plus the easter, summer
    # half term and summer holiday for the 2021/2022 calendar year.
    #
    # This is to allow us to provide a "rolling" calendar of holiday usage
    # calculations
    #
    # @return [Hash] of school_period => OpenStruct
    def school_holiday_calendar_comparison
      academic_year = academic_year_for_comparison

      holidays_for_academic_year = @holidays.holidays.select { |h| h.academic_year == academic_year }
      comparison_periods = holidays_for_academic_year.map do |holiday|
        # use last year holiday if the holiday hasn't started yet
        if holiday.start_date > @asof_date
          holiday_period_for_previous_year(holiday)
        else
          holiday
        end
      end
      holidays_usage_comparison(school_periods: adding_missing_holidays(comparison_periods))
    end

    private

    # If a school calendar does not have a full set of holidays for the current academic year then there will be
    # missing holidays from the comparison periods generated in +school_holiday_calendar_comparison+ above.
    #
    # Find any missing holiday types and add those to the list of comparison periods using the holidays defined
    # for the previous academic year
    def adding_missing_holidays(comparison_periods)
      year = previous_academic_year
      missing = Holidays::MAIN_HOLIDAY_TYPES.sort - comparison_periods.map(&:type).compact.sort
      comparison_periods.concat(@holidays.holidays.select { |h| h.academic_year == year && missing.include?(h.type) })
    end

    def has_data_for_period?(school_period)
      @meter.amr_data.start_date < school_period.start_date && @meter.amr_data.end_date > end_date(school_period)
    end

    def end_date(school_period)
      if @asof_date > school_period.start_date && @asof_date < school_period.end_date
        @asof_date
      else
        school_period.end_date
      end
    end

    def holiday_period_for_previous_year(school_period)
      @holidays.same_holiday_previous_year(school_period)
    end

    def academic_year_for_comparison
      if @asof_date.month > 8
        @asof_date.year..(@asof_date.year + 1)
      else
        (@asof_date.year - 1)..@asof_date.year
      end
    end

    def previous_academic_year
      if @asof_date.month > 8
        (@asof_date.year - 1)..@asof_date.year
      else
        (@asof_date.year - 2)..(@asof_date.year - 1)
      end
    end

    def usage_for_period(school_period, data_type = :kwh)
      @meter.amr_data.kwh_date_range(school_period.start_date, end_date(school_period), data_type)
    end
  end
end

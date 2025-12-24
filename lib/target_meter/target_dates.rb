# frozen_string_literal: true

class TargetMeter
  class TargetDates
    class TargetBeforeExistingDataStartBackfillNotSupported < StandardError; end
    class TargetDateBeforeFirstMeterStartDate < StandardError; end
    include Logging

    DAYSINYEAR = 365
    def initialize(original_meter, target)
      @original_meter = original_meter
      @target = target
    end

    def to_s
      serialised_dates_for_debug
    end

    def check_consistent
      # TODO(PH, 2Mar2022) - could do with further checks for date self-consistency and support
      # TODO can be removed now?
      return unless target_start_date < original_meter_start_date

      raise TargetBeforeExistingDataStartBackfillNotSupported,
            "Target start date #{target_start_date} must be after first meter reading #{original_meter_start_date}"
    end

    def target_start_date
      @target_start_date ||= calculate_target_start_date
    end

    def target_end_date
      original_target_start_date + DAYSINYEAR - 1
    end

    def original_target_start_date
      [@target.first_target_date, @original_meter.amr_data.end_date - DAYSINYEAR].max
    end

    # case where user set target date where < 1 year data and no annual_kwh estimate
    # target only available after 1 year data point, so no target from user set
    # target date until 1 year's data, then target data for remainder of year
    # e.g. user target date = 1 Dec 2021, 1st meter date = 1 Mar 2021
    #      targets from 1 Mar 2022 to 1 Dec 2022 but not 1 Dec 2021 to 28 Feb 2022
    def pre_target_date?(date)
      date.between?(original_target_start_date, target_start_date - 1)
    end

    def target_date_range
      target_start_date..target_end_date
    end

    # 'benchmark' = up to 1 year period of real amr_data before target_start_date
    def benchmark_start_date
      [@original_meter.amr_data.start_date, synthetic_benchmark_start_date].max
    end

    def benchmark_end_date
      [synthetic_benchmark_end_date, @original_meter.amr_data.start_date].max
    end

    def benchmark_date_range
      benchmark_start_date..benchmark_end_date
    end

    def original_meter_start_date
      @original_meter.amr_data.start_date
    end

    def original_meter_end_date
      @original_meter.amr_data.end_date
    end

    def original_meter_date_range
      original_meter_start_date..original_meter_end_date
    end

    def synthetic_benchmark_start_date
      target_start_date - DAYSINYEAR
    end

    def synthetic_benchmark_end_date
      target_start_date - 1
    end

    def synthetic_benchmark_date_range
      synthetic_benchmark_start_date..synthetic_benchmark_end_date
    end

    # Used by TargetsService
    #
    # The default start date for new targets is the 1st of the current month.
    #
    # But the most recent data for the aggregate meter might be a few weeks out of date, so
    # instead default to the first of that month instead.
    #
    # In practice this should only ever result in us creating targets with a date of this month,
    # or first of last month, as we're not allowing schools that have data that is more than 30 days out of date to
    # set targets
    #
    # This date is also specific to this fuel type. The front-end will deal with choosing
    # which month (this month, previous month) is used across the different fuel types
    # when it builds the suggested target for the user
    def self.default_target_start_date(original_meter)
      default_date = Date.new(Date.today.year, Date.today.month, 1)
      end_date = original_meter.amr_data.end_date

      if end_date && end_date < default_date
        # use end date year and month to deal with year boundaries
        default_date = Date.new(end_date.year, end_date.month, 1)
      end

      default_date
    end

    # used by TargetsService
    #
    # Should return true if we have at more than a years worth of AMR data
    # but only if that data is not lagging by more than 30 days
    #
    # If its lagging by a few weeks, that's fine so long as we still have about a
    # years worth of data
    #
    # TODO: suggest renaming to: one_year_of_recent_meter_readings
    def self.one_year_of_meter_readings_available_prior_to_1st_date?(original_meter)
      target = TargetAttributes.new(original_meter)

      return target.first_target_date - original_meter.amr_data.start_date > DAYSINYEAR if target.target_set?
      # if target is set, just check there's at least a years worth of data

      # while we could potentially generate a report if data is < 30 days old, we've decided not to allow this.
      # Using TargetMeter.recent_data? to ensure we maintain consistency with TargetsService interface
      return false unless TargetMeter.recent_data?(original_meter)

      # Now, do we have enough data if the user created a target today?
      # Determinee the target start date, then check there's at least a year of data available before then
      default_target_start_date(original_meter) - original_meter.amr_data.start_date > DAYSINYEAR
    end

    # used by TargetsService
    def self.can_calculate_one_year_of_synthetic_data?(original_meter)
      target = TargetAttributes.new(original_meter)

      # TODO(PH, 10Sep2021) - this is arbitrarily set to 30 days for the moment, refine
      if original_meter.fuel_type == :electricity
        TargetDates.minimum_5_school_days_1_weekend_meter_readings?(original_meter)
      else
        start_date = target.target_set? ? target.first_target_date : default_target_start_date(original_meter)
        start_date - original_meter.amr_data.start_date > 30
      end
    end

    def days_benchmark_data
      (benchmark_end_date - benchmark_start_date + 1).to_i
    end

    def days_target_data
      (target_end_date - target_start_date + 1).to_i
    end

    def full_years_benchmark_data?
      if @target.target_set?
        days_benchmark_data >= DAYSINYEAR
      else
        @original_meter.amr_data.days >= DAYSINYEAR
      end
    end

    # circumstance where meter target start date has been bumped
    # forward but would be better if annual estimate provided and
    # full synthetic calculation takes place
    def annual_kwh_estimate_helpful?
      @original_meter.annual_kwh_estimate.nan? &&
        moved_target_start_date_forward? &&
        original_target_start_date - original_meter_start_date < DAYSINYEAR
    end

    def percentage_synthetic_data_in_date_range(start_date, end_date)
      total_days = end_date - start_date + 1
      synthetic_days = (start_date..end_date).count do |date|
        date < benchmark_start_date && date >= synthetic_benchmark_start_date
      end

      return 0.0 if total_days.nil? || total_days.zero?

      (synthetic_days / total_days).to_f
    end

    def final_holiday_date
      hols = @original_meter.meter_collection.holidays
      hols.holidays.last.end_date
    end

    def first_holiday_date
      hols = @original_meter.meter_collection.holidays
      hols.holidays.first.start_date
    end

    def enough_holidays?
      if @target.target_set?
        final_holiday_date >= target_end_date && first_holiday_date <= synthetic_benchmark_start_date
      else
        final_holiday_date >= today + DAYSINYEAR && first_holiday_date <= today - DAYSINYEAR
      end
    end

    def missing_date_range
      synthetic_benchmark_start_date..benchmark_start_date
    end

    def recent_data?
      today > Date.today - 30
    end

    def serialised_dates_for_debug
      {
        target_start_date: target_start_date,
        target_end_date: target_end_date,
        benchmark_start_date: benchmark_start_date,
        benchmark_end_date: benchmark_end_date,
        synthetic_benchmark_start_date: synthetic_benchmark_start_date,
        synthetic_benchmark_end_date: synthetic_benchmark_end_date,
        full_years_benchmark_data: full_years_benchmark_data?,
        original_meter_start_date: original_meter_start_date,
        original_meter_end_date: original_meter_end_date,
        first_holiday_date: first_holiday_date,
        final_holiday_date: final_holiday_date,
        enough_holidays: enough_holidays?,
        holiday_problems: holiday_problems.join(', '),
        recent_data: recent_data?,
        moved_target_start_date_forward: moved_target_start_date_forward?,
        original_target_start_date: original_target_start_date
      }
      # or TargetDates.instance_methods(false).map { |m| [m, self.send(m)]}
    end

    private

    def moved_target_start_date_forward?
      original_target_start_date != target_start_date
    end

    def calculate_target_start_date
      t_date = if @original_meter.annual_kwh_estimate.nan? &&
                  @target.first_target_date - DAYSINYEAR < @original_meter.amr_data.start_date

                 td = [
                   first_day_of_next_month(@original_meter.amr_data.start_date + DAYSINYEAR),
                   @original_meter.amr_data.end_date - DAYSINYEAR
                 ].max
                 logger.info "Moving target start date forward to #{td} as target not set"
                 td
               else
                 [@target.first_target_date, @original_meter.amr_data.end_date - DAYSINYEAR].max
               end

      check_target_start_date_after_first_meter_date(t_date)
      t_date
    end

    def first_day_of_next_month(date)
      date.day == 1 ? date : date.next_month.beginning_of_month
    end

    def check_target_start_date_after_first_meter_date(date)
      return unless date < @original_meter.amr_data.start_date

      raise TargetDateBeforeFirstMeterStartDate,
            "Target start date #{date} before first meter data #{@original_meter.amr_data.start_date}"
    end

    def first_day_of_next_month(date)
      date.day == 1 ? date : date.next_month.beginning_of_month
    end

    def holiday_problems
      school = @original_meter.meter_collection
      school.holidays.check_holidays(school, school.holidays, country: school.country)
    end

    def today
      $ENERGYSPARKSTESTTODAYDATE || @original_meter.amr_data.end_date
    end

    def self.minimum_5_school_days_1_weekend_meter_readings?(meter)
      holidays = meter.meter_collection.holidays
      stats = holidays.day_type_statistics(meter.amr_data.start_date, meter.amr_data.end_date)
      stats[:weekend] >= 2 && stats[:schoolday] >= 5
    end
  end
end

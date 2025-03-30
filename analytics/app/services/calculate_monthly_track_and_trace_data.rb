# frozen_string_literal: true

# calculate up to a 2 year comparison of monthly consumption
# data versus a target
class CalculateMonthlyTrackAndTraceData
  def initialize(school, fuel_type)
    @school = school
    @fuel_type = fuel_type
    @aggregate_meter = @school.aggregate_meter(@fuel_type)
  end

  def raw_data
    @raw_data ||= calculate_raw_data
  end

  private

  def calculate_raw_data
    month_dates = calculate_month_dates
    partial_month_dates_info = calculate_partial_month_dates(month_dates, @aggregate_meter.amr_data.end_date)
    partial_month_dates = partial_month_dates_info.map { |i| i[:date_range] }
    partial_months = partial_month_dates_info.map { |i| i[:partial_month] }

    current_year_kwhs   = kwhs_for_date_ranges(partial_month_dates, @aggregate_meter, target_meter.target_dates.target_start_date)
    full_targets_kwh    = kwhs_for_target_date_ranges(month_dates)
    partial_targets_kwh = kwhs_for_target_date_ranges(partial_month_dates)

    prior_year_months = prior_year_month_dates(month_dates)
    percentage_synthetic = percent_synthetic_data(prior_year_months, target_meter)

    partial_last_year_unadjusted_kwh = unadjusted_target(partial_month_dates, target_meter)
    full_last_year_unadjusted_kwh    = unadjusted_target(month_dates,         target_meter)

    full_cumulative_current_year_kwhs           = accumulate(current_year_kwhs)
    partial_cumulative_targets_kwhs             = accumulate(partial_targets_kwh)
    partial_cumulative_last_year_unadjusted_kwh = accumulate(partial_last_year_unadjusted_kwh)

    {
      current_year_kwhs: current_year_kwhs,
      full_targets_kwh: full_targets_kwh,
      partial_targets_kwh: partial_targets_kwh,
      partial_last_year_unadjusted_kwh: partial_last_year_unadjusted_kwh,
      full_last_year_unadjusted_kwh: full_last_year_unadjusted_kwh,

      full_cumulative_current_year_kwhs: full_cumulative_current_year_kwhs,
      full_cumulative_targets_kwhs: accumulate(full_targets_kwh),
      partial_cumulative_targets_kwhs: partial_cumulative_targets_kwhs,
      percentage_synthetic: percentage_synthetic,

      monthly_performance: performance(current_year_kwhs, partial_targets_kwh),
      cumulative_performance: performance(full_cumulative_current_year_kwhs, partial_cumulative_targets_kwhs),

      monthly_performance_versus_last_year: performance(current_year_kwhs, partial_last_year_unadjusted_kwh),
      cumulative_performance_versus_last_year: performance(full_cumulative_current_year_kwhs, partial_cumulative_last_year_unadjusted_kwh),

      current_year_date_ranges: month_dates,
      partial_months: partial_months,
      first_target_date: target_meter.target_dates.target_start_date
    }
  end

  def performance(kwhs, target_kwhs)
    kwhs.map.with_index do |_kwh, i|
      percent = kwhs[i].nil? || target_kwhs[i].nil? ? nil : ((kwhs[i] - target_kwhs[i]) / target_kwhs[i])
      percent = 0.0 if target_kwhs[i] == 0.0 && (percent.nil? || percent.nan? || percent.infinite?)
      percent
    end
  end

  def kwhs_for_date_ranges(date_ranges, meter, target_start_date)
    date_ranges.map do |date_range|
      if date_range.nil? || target_start_date > date_range.last
        nil
      else
        kwh_date_range(meter, date_range.first, date_range.last)
      end
    end
  end

  def kwhs_for_target_date_ranges(date_ranges)
    date_ranges.map do |date_range|
      if date_range.nil?
        nil
      else
        total = date_range.map do |date|
          if target_meter.target_dates.pre_target_date?(date)
            # case where no annual kwh estimate, target bumped forward
            0.0
          else
            kwh_zero_if_not_exists(target_meter, date)
          end
        end.sum.to_f

        total == 0.0 ? nil : total
      end
    end
  end

  def percent_synthetic_data(date_ranges, target_meter)
    date_ranges.map do |date_range|
      if date_range.nil?
        nil
      else
        target_meter.target_dates.percentage_synthetic_data_in_date_range(date_range.first, date_range.last)
      end
    end
  end

  # some front end users want the underlying synthetic representation of last year's
  # data rather than the target, so reverse engineer it
  def unadjusted_target(date_ranges, meter)
    date_ranges.map do |date_range|
      if date_range.nil?
        nil
      else
        (date_range.first..date_range.last).map do |date|
          target_percent = target_meter.target.target(date)
          target_percent == 0.0 ? 0.0 : (kwh_zero_if_not_exists(meter, date) / target_percent)
        end.sum
      end
    end
  end

  def kwh_zero_if_not_exists(meter, date)
    meter.amr_data.date_exists?(date) ? meter.amr_data.one_day_kwh(date) : 0.0
  end

  def kwh_date_range(meter, start_date, end_date)
    meter.amr_data.kwh_date_range(start_date, end_date)
  end

  def calculate_month_dates
    start_date = target_meter.target_dates.original_target_start_date
    months = start_date.day == 1 ? 12 : 13

    (0..(months - 1)).map do |_month_index|
      end_date = [DateTimeHelper.last_day_of_month(start_date), target_meter.target_dates.target_end_date].min
      month_date_range = start_date..end_date
      start_date = end_date + 1
      month_date_range
    end
  end

  def prior_year_month_dates(month_dates)
    month_dates.map do |partial_month_range|
      month_in_of_previous_year(partial_month_range)
    end
  end

  def month_in_of_previous_year(partial_month_range)
    sd = corresponding_date_in_previous_year(partial_month_range.first)
    ed = corresponding_date_in_previous_year(partial_month_range.last)
    sd..ed
  end

  def corresponding_date_in_previous_year(date)
    if Date.leap?(date.year) && date.month == 2 && date.day == 29
      Date.new(date.year - 1, date.month, 28)
    else
      Date.new(date.year - 1, date.month, date.day)
    end
  end

  # full months before last meter date, month_start to meter_date during month, then nils for future months
  # e.g [ 1Sep2020..30Sep2020, 1Oct2020..31Oct2020, 1Nov2020..15Nov2020, nil,nil,nil......]
  def calculate_partial_month_dates(month_dates, last_meter_date)
    month_dates.map do |month_date_range|
      if month_date_range.first.year == last_meter_date.year && month_date_range.first.month == last_meter_date.month
        {
          date_range: month_date_range.first..last_meter_date,
          partial_month: DateTimeHelper.last_day_of_month(last_meter_date) != last_meter_date,
          days_in_month: month_date_range.last - month_date_range.first + 1
        }
      elsif month_date_range.first > last_meter_date
        {
          date_range: nil,
          partial_month: false,
          days_in_month: month_date_range.last - month_date_range.first + 1
        }
      else
        {
          date_range: month_date_range,
          partial_month: DateTimeHelper.first_day_of_month(month_date_range.first) != month_date_range.first,
          days_in_month: month_date_range.last - month_date_range.first + 1
        }
      end
    end
  end

  def accumulate(arr)
    running_total = 0.0
    arr.map do |v|
      if v.nil?
        nil
      else
        running_total += v
      end
    end
  end

  def target_meter
    @school.target_school.aggregate_meter(@fuel_type)
  end
end

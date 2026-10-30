require_relative 'alert_period_comparison_base'

class AlertHolidayComparisonBase < AlertPeriodComparisonBase
  private def period_type
    'holiday'
  end

  def timescale
    I18n.t("#{i18n_prefix}.timescale")
  end

  protected def period_name(period)
    I18nHelper.holiday(period.type)
  end

  protected def truncate_period_to_available_meter_data(period)
    return nil if period.nil?
    return period if period.start_date >= aggregate_meter.amr_data.start_date && period.end_date <= aggregate_meter.amr_data.end_date
    start_date = [period.start_date, aggregate_meter.amr_data.start_date].max
    end_date = [period.end_date, aggregate_meter.amr_data.end_date].min
    if end_date >= start_date
      @truncated_current_period = true
      return SchoolDatePeriod.new(period.type, "#{period.title} truncated to available meter data", start_date, end_date)
    end
    nil
  end

  # relevant if asof date immediately at end of period or up to
  # 3 weeks after
  private def calculate_time_of_year_relevance(asof_date)
    current_period, _previous_period = last_two_periods(asof_date)
    return 0.0 if current_period.nil?
    # relevant during period, subject to 'enough_data'
    return 10.0 if enough_days_in_period(current_period, asof_date)
    days_from_end_of_period_to_asof_date = asof_date - current_period.end_date
    return 0.0 if days_from_end_of_period_to_asof_date > DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD
    percent_into_post_holiday_period = (days_from_end_of_period_to_asof_date - DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD) / DAYS_ALERT_RELEVANT_AFTER_CURRENT_PERIOD
    weight =  percent_into_post_holiday_period * 2.5
    10.0 - weight # scale down relevance of holiday comparison from 10.0 to 7.5 over relevance period (e.g. 3 weeks)
  end

end

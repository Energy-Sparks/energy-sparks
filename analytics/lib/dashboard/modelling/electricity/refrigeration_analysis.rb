class RefrigerationAnalysis
  def initialize(school)
    @school = school
    @amr_data = @school.aggregated_electricity_meters.amr_data
    @holidays = @school.holidays
  end

  def attempt_to_detect_refrigeration_being_turned_off_over_summer_holidays(period, drop_criteria)
    weekend_baseloads, holiday_baseloads = weekend_versus_holiday_baseloads(period)

    holiday_average_baseload_kw = holiday_baseloads.sum / holiday_baseloads.length
    weekend_average_baseload_kw = weekend_baseloads.sum / weekend_baseloads.length
    change_kw = holiday_average_baseload_kw - weekend_average_baseload_kw
    annualised_£ = -1 * change_kw * 24 * 365 * @amr_data.current_tariff_rate_£_per_kwh
    holiday_£    = -1 * change_kw * 24 * holiday_baseloads.length * @amr_data.current_tariff_rate_£_per_kwh

    {
      start_date:             period.start_date,
      end_date:               period.end_date,
      weekend_baseload_kw:    weekend_average_baseload_kw,
      holiday_baseload_kw:    holiday_average_baseload_kw,
      change_in_baseload_kw:  change_kw,
      signifcant_change:      change_kw < drop_criteria ? 'Signifcant reduction' : 'No significant reduction',
      annualised_saving_£:    annualised_£,
      holiday_saving_£:       holiday_£,
      holiday_name:           period.title
    }
  end

  def periods_around_summer_holidays
    summer_holidays = @holidays.find_all_summer_holidays_date_range(first_meter_reading_date, latest_meter_reading_date)
    holiday_periods_with_margin_either_side(summer_holidays)
  end

  private

  def weekend_versus_holiday_baseloads(period)
    weekend_baseloads = []
    holiday_baseloads = []
    (period.start_date..period.end_date).each do |date|
      min_evening_baseload_kw = @amr_data.days_kwh_x48(date)[42..47].min * 2.0
      if @holidays.holiday?(date)
        holiday_baseloads.push(min_evening_baseload_kw)
      elsif @holidays.weekend?(date)
        weekend_baseloads.push(min_evening_baseload_kw)
      end
    end
    [weekend_baseloads, holiday_baseloads]
  end

  def first_meter_reading_date
    @amr_data.start_date
  end

  def latest_meter_reading_date
    @amr_data.end_date
  end

  def holiday_periods_with_margin_either_side(holidays, margin_days_before = 20)
    holidays.map do |summer_holiday|
      start_date = summer_holiday.start_date - margin_days_before
      if start_date >= first_meter_reading_date
        end_date = [latest_meter_reading_date, summer_holiday.end_date].min
        SchoolDatePeriod.new(:summer_holiday_with_margin, summer_holiday.title, start_date, end_date)
      else
        nil
      end
    end.compact
  end
end

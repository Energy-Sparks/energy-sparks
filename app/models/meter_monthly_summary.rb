class MeterMonthlySummary

  ALL_ORIG = ['ORIG'].to_set

  def self.from_meter(meter)
    today = Time.zone.today
    Periods::FixedAcademicYear.enumerator(start_date(today), today).each do |period_start, period_end|
      readings = meter.amr_validated_readings.where(reading_date: period_start..period_end)
      readings_by_month = readings.group_by { |r| r.recorded_on.beginning_of_month }

      result = readings_by_month.map do |month_start, month_readings|
        days_with_readings = month_readings.map(&:recorded_on).to_set

        # Build the expected set of all days in that month
        all_days_in_month = (month_start..month_start.end_of_month).to_a

        statuses = month_readings.map(&:status).to_set

        missing_days = all_days_in_month.reject { |day| days_with_readings.include?(day) }
        status = if missing_days.any?
                   :incomplete
                 elsif statuses == ALL_ORIG
                   :actual
                 else
                   :corrected
                 end
      end
    end
  end

  def self.start_date(today)
    year = today.month >= 9 ? today.year - 1 : today.year - 2
    Date.new(year, 9, 1)
  end
end

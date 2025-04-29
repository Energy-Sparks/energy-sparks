# == Schema Information
#
# Table name: meter_monthly_summaries
#
#  consumption :float            is an Array
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  meter_id    :bigint(8)
#  quality     :enum             is an Array
#  total       :float
#  updated_at  :datetime         not null
#  year        :integer
#
# Indexes
#
#  index_meter_monthly_summaries_on_meter_id  (meter_id)
#
class MeterMonthlySummary < ApplicationRecord
  ALL_ORIG = ['ORIG'].to_set

  def self.from_meter(meter)
    today = Time.zone.today
    Periods::FixedAcademicYear.enumerator(start_date(today, 2), today).filter_map do |period_start, period_end|
      readings = meter.amr_validated_readings.where(reading_date: period_start..period_end)
      next if readings.empty?

      readings_by_month = readings.group_by { |r| r.reading_date.beginning_of_month }

      consumption = Array.new(0, 0)
      quality = []
      readings_by_month.each do |month_start, month_readings|
        days_with_readings = month_readings.map(&:reading_date).to_set
        all_days_in_month = (month_start..month_start.end_of_month)
        missing_days = all_days_in_month.reject { |day| days_with_readings.include?(day) }
        statuses = month_readings.map(&:status).to_set
        index = month_start.month - 1
        quality[index] = if missing_days.any?
                           :incomplete
                         elsif statuses == ALL_ORIG
                           :actual
                         else
                           :corrected
                         end
        consumption[index] = month_readings.map(&:one_day_kwh).sum
      end
      # debugger
      consumption.map! { |x| x.nil? ? 0 : x }
      create!(year: period_start.year, consumption:, quality:, total: consumption.sum)
    end
  end

  def self.start_date(today, years)
    year = today.month >= 9 ? today.year - (years - 1) : today.year - years
    Date.new(year, 9, 1)
  end
end

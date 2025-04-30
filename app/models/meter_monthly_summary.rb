# == Schema Information
#
# Table name: meter_monthly_summaries
#
#  consumption :float            not null, is an Array
#  created_at  :datetime         not null
#  id          :bigint(8)        not null, primary key
#  meter_id    :bigint(8)        not null
#  quality     :enum             not null, is an Array
#  total       :float            not null
#  updated_at  :datetime         not null
#  year        :integer          not null
#
# Indexes
#
#  index_meter_monthly_summaries_on_meter_id           (meter_id)
#  index_meter_monthly_summaries_on_meter_id_and_year  (meter_id,year) UNIQUE
#
class MeterMonthlySummary < ApplicationRecord
  belongs_to :meter

  validates :consumption, presence: true
  validates :quality, presence: true
  validates :total, presence: true
  validates :year, uniqueness: { scope: :meter_id }

  def self.from_meter(meter)
    today = Time.zone.today
    Periods::FixedAcademicYear.enumerator(start_date(today, 2), today).filter_map do |period_start, period_end|
      readings = meter.amr_validated_readings.where(reading_date: period_start..period_end)
      next if readings.empty?

      readings_by_month = readings.group_by { |r| r.reading_date.beginning_of_month }
      consumption = []
      quality = []
      readings_by_month.each do |month_start, month_readings|
        index = month_start.month - 1
        quality[index] = month_quality(month_start, month_readings)
        consumption[index] = month_readings.sum(&:one_day_kwh)
      end
      consumption.map! { |x| x.nil? ? 0 : x }
      summary = find_or_initialize_by(meter:, year: period_start.year)
      summary.assign_attributes(consumption:, quality:, total: consumption.sum)
      summary.save! if summary.changed?
      summary
    end
  end

  private_class_method def self.month_quality(month_start, month_readings)
    days_with_readings = month_readings.map(&:reading_date).to_set
    all_days_in_month = (month_start..month_start.end_of_month)
    missing_days = all_days_in_month.reject { |day| days_with_readings.include?(day) }
    if missing_days.any?
      :incomplete
    elsif month_readings.to_set(&:status).to_a == %w[ORIG]
      :actual
    else
      :corrected
    end
  end

  private_class_method def self.start_date(today, years)
    year = today.month >= 9 ? today.year - (years - 1) : today.year - years
    Date.new(year, 9, 1)
  end
end

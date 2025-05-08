# frozen_string_literal: true

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
#  type        :enum             not null
#  updated_at  :datetime         not null
#  year        :integer          not null
#
# Indexes
#
#  index_meter_monthly_summaries_on_meter_id                    (meter_id)
#  index_meter_monthly_summaries_on_meter_id_and_year_and_type  (meter_id,year,type) UNIQUE
#
class MeterMonthlySummary < ApplicationRecord
  belongs_to :meter

  self.inheritance_column = nil
  validates :type, presence: true
  validates :consumption, presence: true
  validates :quality, presence: true
  validates :total, presence: true
  validates :year, presence: true, uniqueness: { scope: %i[meter_id type] }

  def self.create_or_update_from_school(school, meter_collection)
    today = Time.zone.today
    Periods::FixedAcademicYear.enumerator(start_date(today, 2), today).filter_map do |period_start, period_end|
      school.meters.main_meter.each { |meter| from_main_meter(meter, period_start, period_end) }
      school.meters.electricity.filter(&:has_solar_array?).each do |meter|
        from_solar_meter(meter, meter_collection.meter?(meter.mpan_mprn), period_start, period_end)
      end
    end
  end

  private_class_method def self.from_main_meter(meter, period_start, period_end)
    readings = meter.amr_validated_readings.where(reading_date: period_start..period_end)
    return if readings.empty?

    consumption, quality = consumption_and_quality(readings.group_by { |r| r.reading_date.beginning_of_month },
                                                   :main_meter_month_quality)
    create_or_update_summary(meter, period_start.year, :consumption, consumption, quality)
  end

  private_class_method def self.consumption_and_quality(readings_by_month, quality_method)
    consumption = []
    quality = []
    readings_by_month.each do |month_start, month_readings|
      index = month_start.month - 1
      quality[index] = send(quality_method, month_start, month_readings)
      consumption[index] = month_readings.sum(&:one_day_kwh)
    end
    consumption.map! { |x| x.nil? ? 0 : x }
    [consumption, quality]
  end

  private_class_method def self.create_or_update_summary(meter, year, type, consumption, quality)
    summary = find_or_initialize_by(meter:, year:, type:)
    summary.assign_attributes(consumption:, quality:, total: consumption.sum)
    summary.save! if summary.changed?
    summary
  end

  private_class_method def self.main_meter_month_quality(month_start, month_readings)
    missing_days = calculate_missing_days(month_readings.to_set(&:reading_date), month_start)
    if missing_days.any?
      :incomplete
    elsif month_readings.to_set(&:status).to_a == %w[ORIG]
      :actual
    else
      :corrected
    end
  end

  private_class_method def self.from_solar_meter(meter, meter_collection_meter, period_start, period_end)
    return if meter_collection_meter.nil?

    meter_collection_meter.sub_meters.slice(:generation, :self_consume, :export).each do |type, sub_meter|
      readings = (period_start..period_end).filter_map { |date| sub_meter.amr_data[date] }
      next if readings.empty?

      consumption, quality = consumption_and_quality(readings.group_by { |r| r.date.beginning_of_month },
                                                     :solar_meter_month_quality)
      create_or_update_summary(meter, period_start.year, type, consumption, quality)
    end
  end

  private_class_method def self.solar_meter_month_quality(month_start, month_readings)
    missing_days = calculate_missing_days(month_readings.to_set(&:date), month_start)
    if missing_days.any?
      :incomplete
    else
      types = month_readings.to_set(&:type)
      if types == %w[ORIG].to_set
        :actual
      elsif types.intersect?(%w[SOLR SOLO SOLE BKPV])
        :estimated
      elsif types.intersect?(%w[PROB SOL0])
        :incomplete
      else
        raise "unknown #{month_readings.to_set(&:type)}"
      end
    end
  end

  private_class_method def self.calculate_missing_days(days_with_readings, month_start)
    all_days_in_month = (month_start..month_start.end_of_month)
    all_days_in_month.reject { |day| days_with_readings.include?(day) }
  end

  private_class_method def self.start_date(today, years)
    year = today.month >= 9 ? today.year - (years - 1) : today.year - years
    Date.new(year, 9, 1)
  end
end

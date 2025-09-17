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

  def self.total_sum(meters, year, type)
    meters.sum { |meter| meter.meter_monthly_summaries.find_by(year:, type:)&.total || 0 }.round(2)
  end

  def self.create_or_update_from_school(school, meter_collection)
    today = Time.zone.today
    meter_ids = school.meters.to_h { |meter| [meter.mpan_mprn, meter.id] }
    Periods::FixedAcademicYear.enumerator(start_date(today, 2), today).filter_map do |period_start, period_end|
      (meter_collection.heat_meters + meter_collection.electricity_meters).each do |meter|
        meter = meter.sub_meters[:mains_consume] if meter.sub_meters.key?(:mains_consume)
        from_meter_collection_meter(meter_ids.fetch(meter.id), meter, period_start, period_end,
                                    :mains_meter_month_quality, :consumption)
      end
      meter_collection.electricity_meters.filter(&:solar_pv_panels?).each do |meter|
        from_solar_meter(meter_ids.fetch(meter.sub_meters[:mains_consume].id), meter,
                         period_start, period_end)
      end
    end
  end

  def self.start_date(today, years)
    year = today.month >= 9 ? today.year - (years - 1) : today.year - years
    Date.new(year, 9, 1)
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

  private_class_method def self.create_or_update_summary(meter_id, year, type, consumption, quality)
    summary = find_or_initialize_by(meter_id:, year:, type:)
    summary.assign_attributes(consumption:, quality:, total: consumption.sum)
    summary.save! if summary.changed?
    summary
  end

  private_class_method def self.mains_meter_month_quality(month_start, month_readings)
    missing_days = calculate_missing_days(month_readings.to_set(&:date), month_start)
    if missing_days.any?
      :incomplete
    elsif month_readings.to_set(&:type) == %w[ORIG].to_set
      :actual
    else
      :corrected
    end
  end

  private_class_method def self.from_solar_meter(meter_id, meter_collection_meter, period_start, period_end)
    meter_collection_meter.sub_meters.slice(:generation, :self_consume, :export).each do |type, sub_meter|
      from_meter_collection_meter(meter_id, sub_meter, period_start, period_end, :solar_meter_month_quality, type)
    end
  end

  private_class_method def self.from_meter_collection_meter(meter_id, meter, period_start, period_end, quality_method,
                                                            type)
    readings = (period_start..period_end).filter_map { |date| meter.amr_data[date] }
    return if readings.empty?

    consumption, quality = consumption_and_quality(readings.group_by { |r| r.date.beginning_of_month }, quality_method)
    create_or_update_summary(meter_id, period_start.year, type, consumption, quality)
  end

  private_class_method def self.solar_meter_month_quality(month_start, month_readings)
    missing_days = calculate_missing_days(month_readings.to_set(&:date), month_start)
    if missing_days.any?
      :incomplete
    else
      types = month_readings.to_set(&:type)
      if %w[ORIG SOLN].to_set.superset?(types)
        :actual
      elsif types.intersect?(%w[SOLR SOLO SOLE BKPV])
        :estimated
      elsif types.intersect?(%w[PROB SOL0 ZMDR E0H1])
        :incomplete
      else
        raise "unknown #{types} - #{month_start} #{month_readings}"
      end
    end
  end

  private_class_method def self.calculate_missing_days(days_with_readings, month_start)
    all_days_in_month = (month_start..month_start.end_of_month)
    all_days_in_month.reject { |day| days_with_readings.include?(day) }
  end
end

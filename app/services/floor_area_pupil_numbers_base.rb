# frozen_string_literal: true

class FloorAreaPupilNumbersBase
  DEFAULT_START_DATE = Date.new(2000, 1, 1)
  DEFAULT_END_DATE   = Date.new(2050, 1, 1)

  attr_reader :area_pupils_history

  def initialize(school_attributes, key, default, add_attribute: false)
    @key = key
    @default = default
    @add_attribute = add_attribute
    @area_pupils_history = process_meter_attributes(school_attributes)
  end

  def value(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? @default : calculate_days_weighted_value(start_date, end_date)
  end

  private

  def process_meter_attributes(attributes)
    return nil if attributes.nil?

    attributes.select { |period| period.key?(@key) }
              .map do |period|
      { start_date: period.fetch(:start_date, DEFAULT_START_DATE),
        end_date: period.fetch(:end_date, DEFAULT_END_DATE),
        value: period[@key] }.merge(@add_attribute ? { attribute: period } : {})
    end.sort_by { |period| period[:start_date] }
  end

  def calculate_days_weighted_value(start_date, end_date)
    start_date = end_date = Time.zone.today if start_date.nil? || end_date.nil?
    start_index = date_index(@area_pupils_history, start_date)
    end_index   = date_index(@area_pupils_history, end_date)

    return @area_pupils_history[start_index][:value] if start_index == end_index

    weighted_areas = (start_index..end_index).to_a.map do |period_index|
      sd = [@area_pupils_history[period_index][:start_date], start_date].max
      ed = [@area_pupils_history[period_index][:end_date],   end_date].min
      {
        days: 1 + (ed - sd).to_i,
        value: @area_pupils_history[period_index][:value]
      }
    end
    # map then sum to avoid statsample bug
    weighted_areas.sum { |we| we[:days] * we[:value] } / weighted_areas.sum { |we| we[:days] }
  end

  def date_index(arr, date)
    arr.bsearch_index do |p|
      if date < p[:start_date]
        -1
      else
        date > p[:end_date] ? 1 : 0
      end
    end
  end
end

# frozen_string_literal: true

class FloorAreaPupilNumbersBase
  DEFAULT_START_DATE = Date.new(2000, 1, 1)
  DEFAULT_END_DATE   = Date.new(2050, 1, 1)

  attr_reader :attributes

  def initialize(school_attributes, key, default)
    @key = key
    @default = default
    @attributes = process_meter_attributes(school_attributes)
  end

  def value(start_date = nil, end_date = nil)
    @attributes.nil? ? @default : calculate_days_weighted_value(start_date, end_date)
  end

  private

  def process_meter_attributes(attributes)
    return nil if attributes.blank?

    attributes = attributes.select { |period| period.key?(@key) }
                           .map do |period|
      period.merge(start_date: period.fetch(:start_date, DEFAULT_START_DATE),
                   end_date: period.fetch(:end_date, DEFAULT_END_DATE),
                   value: period.delete(@key))
    end
    attributes.sort_by { |period| period[:start_date] }
  end

  def calculate_days_weighted_value(start_date, end_date)
    start_date = end_date = Time.zone.today if start_date.nil? || end_date.nil?
    start_index = date_index(@attributes, start_date)
    end_index   = date_index(@attributes, end_date)

    return @attributes[start_index][:value] if start_index == end_index

    average(@attributes[start_index..end_index], start_date, end_date)
  end

  def average(attributes, start_date, end_date)
    weighted_areas = attributes.map do |attribute|
      [1 + ([attribute[:end_date], end_date].min - [attribute[:start_date], start_date].max).to_i,
       attribute[:value]]
    end
    weighted_areas.sum { |days, value| days * value } / weighted_areas.sum(&:first)
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

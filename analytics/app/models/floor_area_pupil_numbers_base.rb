require 'date'

class FloorAreaPupilNumbersBase
  DEFAULT_START_DATE = Date.new(2000, 1, 1)
  DEFAULT_END_DATE   = Date.new(2050, 1, 1)

  attr_reader :area_pupils_history

  def initialize(school_attributes, floor_area_key, pupil_key)
    return if school_attributes.nil?
    @floor_area_key = floor_area_key
    @pupil_key = pupil_key
    @area_pupils_history = process_meter_attributes(school_attributes) unless school_attributes.nil?
  end

  def floor_area(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? @floor_area : calculate_weighted_floor_area(start_date, end_date)
  end

  def number_of_pupils(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? @number_of_pupils : calculate_weighted_number_of_pupils(start_date, end_date)
  end

  private

  def process_meter_attributes(attributes)
    return nil if attributes.nil?

    attributes.map do |period|
      {
        start_date:         period.fetch(:start_date, DEFAULT_START_DATE),
        end_date:           period.fetch(:end_date,   DEFAULT_END_DATE),
        @floor_area_key =>  period[@floor_area_key],
        @pupil_key      =>  period[@pupil_key],
      }
    end.sort_by{ |period| period[:start_date] }
  end

  def calculate_weighted_floor_area(start_date, end_date)
    calculate_days_weighted_value(@floor_area_key, start_date, end_date)
  end

  def calculate_weighted_number_of_pupils(start_date, end_date)
    calculate_days_weighted_value(@pupil_key, start_date, end_date)
  end

  def calculate_days_weighted_value(field, start_date, end_date)
    start_date = end_date = Date.today if start_date.nil? || end_date.nil?
    start_index = date_index(@area_pupils_history, start_date)
    end_index   = date_index(@area_pupils_history, end_date)

    return @area_pupils_history[start_index][field] if start_index == end_index

    weighted_areas = (start_index..end_index).to_a.map do |period_index|
      sd = [@area_pupils_history[period_index][:start_date], start_date].max
      ed = [@area_pupils_history[period_index][:end_date],   end_date  ].min
      {
        days:  1 + (ed - sd).to_i,
        value: @area_pupils_history[period_index][field]
      }
    end
    # map then sum to avoid statsample bug
    weighted_areas.map{ |we| we[:days] * we[:value] }.sum /  weighted_areas.map{ |we| we[:days] }.sum
  end

  def date_index(arr, date)
    arr.bsearch_index {|p| date < p[:start_date] ? -1 : date > p[:end_date] ? 1 : 0 }
  end
end

require_rel './floor_area_pupil_numbers_base.rb'

class FloorAreaPupilNumbers < FloorAreaPupilNumbersBase
  def initialize(floor_area, number_of_pupils, school_attributes)
    @floor_area = floor_area
    @number_of_pupils = number_of_pupils
    return if school_attributes.nil? || school_attributes[:floor_area_pupil_numbers].nil?
    super(school_attributes[:floor_area_pupil_numbers], :floor_area, :number_of_pupils)
  end

  def floor_area(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? @floor_area : calculate_weighted_floor_area(start_date, end_date)
  end

  def floor_area_changes?
    !@area_pupils_history.nil? && floor_area_changes.count > 1
  end

  def number_of_pupils_changes?
    !@area_pupils_history.nil? && number_of_pupils_changes.count > 1
  end

  def number_of_pupils(start_date = nil, end_date = nil)
    @area_pupils_history.nil? ? @number_of_pupils : calculate_weighted_number_of_pupils(start_date, end_date)
  end

  def process_meter_attributes(attributes)
    user_defined_meter_attributes = super(attributes)
    return nil if user_defined_meter_attributes.nil?

    # cope with case where user inserts an incomplete set of meter attributes
    if user_defined_meter_attributes.first[:start_date] > DEFAULT_START_DATE
      df = defaulted_floor_area_pupils(DEFAULT_START_DATE, user_defined_meter_attributes.first[:start_date] - 1)
      user_defined_meter_attributes.insert(0, df)
    end

    if user_defined_meter_attributes.last[:end_date] < DEFAULT_END_DATE
      df = defaulted_floor_area_pupils(user_defined_meter_attributes.last[:end_date] + 1, DEFAULT_END_DATE)
      user_defined_meter_attributes.push(df)
    end

    user_defined_meter_attributes
  end

  def defaulted_floor_area_pupils(start_date, end_date)
    {
      start_date:         start_date,
      end_date:           end_date,
      floor_area:         @floor_area,
      number_of_pupils:   @number_of_pupils
    }
  end

  private

  def floor_area_changes
    @area_pupils_history.map { |period| period[@floor_area_key] }.uniq
  end

  def number_of_pupils_changes
    @area_pupils_history.map { |period| period[@pupil_key] }.uniq
  end
end

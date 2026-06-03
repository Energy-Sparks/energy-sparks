# frozen_string_literal: true

class FloorAreaPupilNumbers < FloorAreaPupilNumbersBase
  def initialize(school_attributes, key, default)
    school_attributes = school_attributes[:floor_area_pupil_numbers]
    super
  end

  private

  def process_meter_attributes(attributes)
    user_defined_meter_attributes = super
    return nil if user_defined_meter_attributes.blank?

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
    { start_date:, end_date:, value: @default }
  end
end

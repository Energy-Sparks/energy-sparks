# frozen_string_literal: true

module MeterAttributes
  class FloorAreaPupilNumbersChangeOverTimeOverride < MeterAttributeTypes::AttributeBase
    id :floor_area_pupil_numbers
    aggregate_over :floor_area_pupil_numbers
    name 'Schools > Changing floor area and pupil numbers over time'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        floor_area: MeterAttributeTypes::Float.define,
        number_of_pupils: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end
end

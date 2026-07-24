# frozen_string_literal: true

module MeterAttributes
  class PartialMeterFloorAreaPupilNumberOverride < MeterAttributeTypes::AttributeBase
    id :partial_meter_coverage
    key :partial_meter_coverage
    aggregate_over :partial_meter_coverage
    name 'Schools > Override percent of floor area or pupil numbers covered by meter'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        percent_floor_area: MeterAttributeTypes::Float.define(required: true),
        percent_pupil_numbers: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end
end

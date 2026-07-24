# frozen_string_literal: true

module MeterAttributes
  class PartialMeterFloorAreaPupilNumberDateRangeOverride < MeterAttributeTypes::AttributeBase
    id :partial_meter_coverage_date_range
    key :partial_meter_coverage_date_range
    aggregate_over :meter_corrections
    name 'Schools > Override percent of floor area or pupil numbers covered by meter - with date ranges'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define(required: true),
        percent_floor_area: MeterAttributeTypes::Float.define(required: true),
        percent_pupil_numbers: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end
end

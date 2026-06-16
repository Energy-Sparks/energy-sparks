# frozen_string_literal: true

module MeterAttributes
  class StorageHeaterPartialMeterFloorAreaPupilNumberOverride < MeterAttributeTypes::AttributeBase
    id :storage_heater_partial_meter_coverage
    key :storage_heater_partial_meter_coverage
    aggregate_over :storage_heater_partial_meter_coverage
    name 'Storage Heaters > Override percent of floor area or pupil numbers covered by storage heaters'
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

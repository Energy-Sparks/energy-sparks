# frozen_string_literal: true

module MeterAttributes
  class ReadingsStartDate < MeterAttributeTypes::AttributeBase
    id :meter_corrections_readings_start_date
    key :readings_start_date
    aggregate_over :meter_corrections
    name 'Meter correction > Readings start date'
    structure MeterAttributeTypes::Date.define(required: true)
  end
end

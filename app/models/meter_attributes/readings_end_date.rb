# frozen_string_literal: true

module MeterAttributes
  class ReadingsEndDate < MeterAttributeTypes::AttributeBase
    id :meter_corrections_readings_end_date
    key :readings_end_date
    aggregate_over :meter_corrections
    name 'Meter correction > Readings end date'
    structure MeterAttributeTypes::Date.define(required: true)
  end
end

# frozen_string_literal: true

module MeterAttributes
  class AutoInsertMissingReadings < MeterAttributeTypes::AttributeBase
    id :meter_corrections_auto_insert_missing_readings
    key :auto_insert_missing_readings
    aggregate_over :meter_corrections

    name 'Meter correction > Auto insert missing readings'
    description 'A meter correction that uses past data to fill in readings that are missing. Useful for schools ' \
                'with flaky meters.'

    structure MeterAttributeTypes::Hash.define(
      structure: { type: MeterAttributeTypes::Symbol.define(allowed_values: [:weekends], required: true) }
    )
  end
end

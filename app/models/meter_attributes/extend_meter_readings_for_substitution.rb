# frozen_string_literal: true

module MeterAttributes
  class ExtendMeterReadingsForSubstitution < MeterAttributeTypes::AttributeBase
    id :meter_corrections_extend_meter_readings_for_substitution
    key :extend_meter_readings_for_substitution
    aggregate_over :meter_corrections
    name 'Meter correction > Extend meter reading range for substitutions'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: false),
        end_date: MeterAttributeTypes::Date.define(required: false)
      }
    )
  end
end

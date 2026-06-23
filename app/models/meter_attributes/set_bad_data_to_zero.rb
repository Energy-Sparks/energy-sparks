# frozen_string_literal: true

module MeterAttributes
  class SetBadDataToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_set_bad_data_to_zero
    key :set_bad_data_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set bad data to zero'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define(required: true)
      }
    )
  end
end

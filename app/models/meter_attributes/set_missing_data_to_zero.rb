# frozen_string_literal: true

module MeterAttributes
  class SetMissingDataToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_set_missing_data_to_zero
    key :set_missing_data_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > Set missing data to zero'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: false),
        end_date: MeterAttributeTypes::Date.define(required: false),
        zero_up_until_yesterday: MeterAttributeTypes::Boolean.define(
          required: false,
          hint: 'if set true will set zero values up until yesterday, else up until the last meter reading'
        )
      }
    )
  end
end

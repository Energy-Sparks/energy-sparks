# frozen_string_literal: true

module MeterAttributes
  class NoHeatingInSummerSetMissingToZero < MeterAttributeTypes::AttributeBase
    id :meter_corrections_no_heating_in_summer_set_missing_to_zero
    key :no_heating_in_summer_set_missing_to_zero
    aggregate_over :meter_corrections
    name 'Meter correction > No heating in summer set missing to zero'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_toy: MeterAttributeTypes::TimeOfYear.define(required: true),
        end_toy: MeterAttributeTypes::TimeOfYear.define(required: true)
      }
    )
  end
end

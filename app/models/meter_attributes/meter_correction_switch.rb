# frozen_string_literal: true

module MeterAttributes
  class MeterCorrectionSwitch < MeterAttributeTypes::AttributeBase
    id :meter_corrections_switch
    aggregate_over :meter_corrections
    name 'Meter correction > Switch'
    structure MeterAttributeTypes::Symbol.define(required: true,
                                                 allowed_values: %i[set_all_missing_to_zero correct_zero_partial_data])
  end
end

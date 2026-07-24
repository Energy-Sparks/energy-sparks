# frozen_string_literal: true

module MeterAttributes
  class FunctionSwitch < MeterAttributeTypes::AttributeBase
    id :function_switch
    aggregate_over :function
    name 'Meter > Energy Use'

    structure MeterAttributeTypes::Symbol.define(required: true,
                                                 allowed_values: %i[heating_only kitchen_only hotwater_only])
  end
end

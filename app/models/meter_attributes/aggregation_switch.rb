# frozen_string_literal: true

module MeterAttributes
  class AggregationSwitch < MeterAttributeTypes::AttributeBase
    id :aggregation_switch
    aggregate_over :aggregation
    name 'Meter > Data presentation'

    structure MeterAttributeTypes::Symbol.define(
      required: true,
      allowed_values: %i[ignore_start_date deprecated_include_but_ignore_start_date
                         deprecated_include_but_ignore_end_date]
    )
  end
end

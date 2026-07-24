# frozen_string_literal: true

module MeterAttributes
  class RescaleAmrData < MeterAttributeTypes::AttributeBase
    id :meter_corrections_rescale_amr_data
    key :rescale_amr_data
    aggregate_over :meter_corrections
    name 'Meter correction > Rescale AMR data'
    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define(required: true),
        scale: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end
end

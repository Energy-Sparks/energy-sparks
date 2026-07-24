# frozen_string_literal: true

module MeterAttributes
  class LowCarbonHub < MeterAttributeTypes::AttributeBase
    id :low_carbon_hub_meter_id
    key :low_carbon_hub_meter_id
    name 'Solar > Low carbon hub meter ID'

    structure MeterAttributeTypes::Integer.define(required: true, min: 0)
  end
end

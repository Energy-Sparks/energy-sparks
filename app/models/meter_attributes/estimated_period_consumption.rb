# frozen_string_literal: true

module MeterAttributes
  class EstimatedPeriodConsumption < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :estimated_period_consumption
    aggregate_over :estimated_period_consumption
    name 'Targets > Estimated consumption for period'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(required: true),
        end_date: MeterAttributeTypes::Date.define(required: true),
        kwh: MeterAttributeTypes::Float.define(required: true)
      }
    )
  end
end

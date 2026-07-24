# frozen_string_literal: true

module MeterAttributes
  class TargetingAndTracking < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :targeting_and_tracking
    aggregate_over :targeting_and_tracking
    name 'Targets > Setting of Targets for Targeting and Tracking'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        start_date: MeterAttributeTypes::Date.define(hint: 'start of year setting target for (versus previous year)'),
        target: MeterAttributeTypes::Float.define(hint: 'e.g. 0.95 = a 5% reduction over previous year')
      }
    )
  end
end

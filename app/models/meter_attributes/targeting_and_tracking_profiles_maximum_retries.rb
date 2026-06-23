# frozen_string_literal: true

module MeterAttributes
  class TargetingAndTrackingProfilesMaximumRetries < MeterAttributeTypes::AttributeBase
    id :targeting_and_tracking_profiles_maximum_retries
    key :targeting_and_tracking_profiles_maximum_retries

    name 'Targets > Targets profile substitution limit (temperature compensation)'
    description 'Used to override targeting and tracking system maximum automatic nil profiles substituted in the ' \
                'event more are required - should only be added after review by an ebergy analyst'

    structure MeterAttributeTypes::Hash.define(
      structure: {
        number_of_retries: MeterAttributeTypes::Integer.define(required: true)
      }
    )
  end
end

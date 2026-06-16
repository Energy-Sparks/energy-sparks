# frozen_string_literal: true

module MeterAttributes
  class OpenCloseTimesAttributes < MeterAttributeTypes::AttributeBase
    analytics_internal true
    id :open_close_times
    aggregate_over :open_close_times
    name 'School and community function opening and closing times'

    def self.time_of_day_range
      MeterAttributeTypes::Hash.define(
        required: false,
        structure: {
          day_of_week: MeterAttributeTypes::Symbol.define(required: true,
                                                          allowed_values: OpenCloseTime.day_of_week_types),
          from: MeterAttributeTypes::TimeOfDay.define(required: true),
          to: MeterAttributeTypes::TimeOfDay.define(required: true)
        }
      )
    end

    structure MeterAttributeTypes::Hash.define(
      structure: {
        type: MeterAttributeTypes::Symbol.define(
          required: true, allowed_values: OpenCloseTime.user_configurable_community_use_types.keys
        ),
        holiday_calendar: MeterAttributeTypes::Symbol.define(required: true,
                                                             allowed_values: OpenCloseTime.calendar_types),
        start_date: MeterAttributeTypes::Date.define,
        end_date: MeterAttributeTypes::Date.define,
        fuel_types: MeterAttributeTypes::Symbol.define(required: true,
                                                       allowed_values: OpenCloseTime.fuel_type_choices),
        time0: time_of_day_range,
        time1: time_of_day_range,
        time2: time_of_day_range,
        time3: time_of_day_range,
        fixed_power_kw: MeterAttributeTypes::Float.define(min: 0.0, hint: 'flood lighting only')
      }
    )
  end
end

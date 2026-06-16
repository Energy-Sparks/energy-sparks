# frozen_string_literal: true

module MeterAttributes
  def self.all(filter: false)
    constants.sort
             .map { |constant_name| const_get(constant_name) }
             .reject { |constant| filter && constant.internal? }
             .index_by(&:attribute_id)
  end

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
end

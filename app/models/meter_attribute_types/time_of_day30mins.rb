# frozen_string_literal: true

module MeterAttributeTypes
  class TimeOfDay30mins < AttributeType
    self.type = :time_of_day_30
    def _parse(input)
      return nil if missing_value?(input[:hour]) || missing_value?(input[:minutes])
      ::TimeOfDay30mins.new(input[:hour].to_i, input[:minutes].to_i)
    end
  end
end

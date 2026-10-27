# frozen_string_literal: true

module MeterAttributeTypes
  class TimeOfDay < AttributeType
    self.type = :time_of_day
    def _parse(input)
      return nil if missing_value?(input[:hour]) || missing_value?(input[:minutes])
      ::TimeOfDay.new(input[:hour].to_i, input[:minutes].to_i)
    end
  end
end

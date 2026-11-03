# frozen_string_literal: true

module MeterAttributeTypes
  class TimeOfYear < AttributeType
    self.type = :time_of_year
    def _parse(input)
      return nil if missing_value?(input[:month]) || missing_value?(input[:day_of_month])
      ::TimeOfYear.new(input[:month].to_i, input[:day_of_month].to_i)
    end
  end
end

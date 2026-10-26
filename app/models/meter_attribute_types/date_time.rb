# frozen_string_literal: true

module MeterAttributeTypes
  class DateTime < AttributeType
    self.type = :date_time
    def _parse(input)
      ::DateTime.parse(input)
    end
  end
end

# frozen_string_literal: true

module MeterAttributeTypes
  class Date < AttributeType
    self.type = :date
    def _parse(input)
      ::Date.parse(input)
    end
  end
end

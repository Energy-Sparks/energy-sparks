# frozen_string_literal: true

module MeterAttributeTypes
  class String < AttributeType
    self.type = :string
    def _parse(value)
      value.to_s
    end
  end
end

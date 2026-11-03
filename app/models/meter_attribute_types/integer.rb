# frozen_string_literal: true

module MeterAttributeTypes
  class Integer < Number
    self.type = :integer
    def _parse(value)
      value.to_i
    end
  end
end

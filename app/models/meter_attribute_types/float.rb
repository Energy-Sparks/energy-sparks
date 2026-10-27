# frozen_string_literal: true

module MeterAttributeTypes
  class Float < Number
    self.type = :float
    def _parse(value)
      value.to_f
    end
  end
end

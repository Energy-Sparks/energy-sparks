# frozen_string_literal: true

module MeterAttributeTypes
  class Boolean < AttributeType
    self.type = :boolean
    def _parse(input)
      ['true', '1'].include?(input.to_s) ? true : nil
    end
  end
end

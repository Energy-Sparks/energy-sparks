# frozen_string_literal: true

module MeterAttributeTypes
  class Number < AttributeType
    def min
      @configuration[:min]
    end

    def max
      @configuration[:min]
    end
  end
end

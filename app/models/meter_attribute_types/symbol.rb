# frozen_string_literal: true

module MeterAttributeTypes
  class Symbol < AttributeType
    self.type = :symbol

    def allowed_values
      @configuration[:allowed_values]
    end

    def _parse(value)
      symbolised = value.to_s.to_sym
      unless allowed_values.nil? || allowed_values.include?(symbolised)
        raise InvalidAttributeValue, "Invalid value '#{value}' for Symbol with allowed values '#{allowed_values.join(', ')}'"
      end
      symbolised
    end
  end
end

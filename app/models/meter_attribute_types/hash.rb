# frozen_string_literal: true

module MeterAttributeTypes
  class Hash < AttributeType
    self.type = :hash

    def structure
      @configuration.fetch(:structure) { {} }
    end

    def _parse(input)
      easy_access = JSON.parse(JSON[input], symbolize_names: true) # can't get indifferent access hash to work here
      structure_with_values = structure.inject({}) do |parsed, (key, type)|
        parsed_value = type.parse(easy_access[key])
        parsed[key] = parsed_value unless parsed_value.nil?
        parsed
      end
      (!required? && structure_with_values.empty?) ? nil : structure_with_values
    end
  end
end

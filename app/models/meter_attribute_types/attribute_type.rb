# frozen_string_literal: true

module MeterAttributeTypes
  class AttributeType
    class_attribute :type

    def initialize(configuration = {})
      @configuration = configuration
    end

    def required?
      @configuration[:required] == true
    end

    def hint
      @configuration[:hint]
    end

    def parse(input)
      return nil if missing_value?(input)
      _parse(input)
    end

    def self.define(configuration = {})
      new(configuration)
    end

    private

    def missing_value?(input)
      input.nil? || input == ''
    end
  end
end

# frozen_string_literal: true

module AlertTemplateVariablesMixin
  def self.included(base)
    base.include(readers_for(base.const_get(:TEMPLATE_VARIABLES, false)))
  end

  def self.readers_for(template_variables)
    variables = template_variables.keys
    # Class-defined methods take precedence over these default readers.
    Module.new { attr_reader(*variables) }
  end
end

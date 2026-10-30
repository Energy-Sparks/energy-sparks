# frozen_string_literal: true

module AlertTemplateVariablesMixin
  def self.included(base)
    variables = base.const_get(:TEMPLATE_VARIABLES, false).keys
    # Class-defined calculations take precedence over these default readers.
    base.include(Module.new { attr_reader(*variables) })
  end
end

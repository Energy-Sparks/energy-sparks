# frozen_string_literal: true

# Ensures all Simple Form forms use CustomSimpleForm::FormBuilder unless explicitly overridden.
# This allows us to switch between Bootstrap 4 and 5 wrappers based on the Current.bs5 flag
module SimpleFormHelper
  def simple_form_for(record, options = {}, &)
    options[:builder] ||= CustomSimpleForm::FormBuilder
    super
  end
end

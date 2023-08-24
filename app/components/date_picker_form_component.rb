# frozen_string_literal: true

class DatePickerFormComponent < ViewComponent::Base
  attr_reader :form_object_name, :field_name, :value, :errors, :hint

  def initialize(form:, field_name:, value: nil, default_if_nil: DateTime.now.strftime('%d/%m/%Y'), errors: '', hint: '')
    @form_object_name = form.object_name
    @field_name = field_name
    @value = value || default_if_nil
    @errors = errors
    @hint = hint
  end

  def id
    "#{form_object_name}_#{field_name}"
  end

  def name
    "#{form_object_name}[#{field_name}]"
  end

  def datetime_picker_id
    "datepickerformcomponent_#{field_name}"
  end
end

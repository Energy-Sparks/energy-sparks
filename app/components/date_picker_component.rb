# frozen_string_literal: true

class DatePickerComponent < ViewComponent::Base
  attr_reader :form, :field, :label, :value, :date_format

  def initialize(form:, field:, label: nil, value: nil, date_format: 'DD/MM/YYYY')
    @form = form
    @field = field
    @label = label
    @value = value
    @date_format = date_format
  end

  def id
   "datetimepickerform_#{field}"
  end
end

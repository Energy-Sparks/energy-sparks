# frozen_string_literal: true

module Forms
  class EmailReportButtonComponent < ApplicationComponent
    def initialize(path, label, button_class: 'btn btn-sm', modal_title: nil, **_kwargs)
      super
      @path = path
      @label = label
      @button_class = button_class
      @modal_title = modal_title
      id = label.parameterize(separator: '_')
      @modal_id = "email_report_button_modal-#{id}"
      @button_attributes = { 'data-toggle': :modal, 'data-bs-toggle': :modal,
                             'data-target': "##{@modal_id}", 'data-bs-target': "##{@modal_id}" }
      @button_attributes[:type] = :button # if content?
      # debugger
      @label_id = "email_report_button_label-#{id}"
      # @button_attributes[:type] = ''
    end
  end
end

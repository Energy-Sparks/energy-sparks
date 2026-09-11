# frozen_string_literal: true

module Forms
  class EmailReportButtonComponent < ApplicationComponent
    attr_reader :label_id

    def initialize(path, label, button_class: 'btn btn-sm', **kwargs)
      super
      @path = path
      @label = label
      @button_class = button_class
      @modal_title = kwargs[:modal_title]
      @modal_label = kwargs[:modal_label] || @label
      id = label.parameterize(separator: '_')
      @modal_id = "email_report_button_modal-#{id}"
      @label_id = "email_report_button_label-#{id}"
      @school_group = kwargs[:school_group]
    end
  end
end

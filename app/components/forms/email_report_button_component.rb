# frozen_string_literal: true

module Forms
  class EmailReportButtonComponent < ApplicationComponent
    def initialize(path, label, button_class: 'btn btn-sm', **_kwargs)
      super
      @path = path
      @label = label
      @button_class = button_class
    end
  end
end

# frozen_string_literal: true

module Forms
  class EmailReportButtonComponent < ApplicationComponent
    def initialize(path, label, **_kwargs)
      super
      @path = path
      @label = label
    end
  end
end

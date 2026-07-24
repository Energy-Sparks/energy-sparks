# frozen_string_literal: true

module Commercial
  class ExceptionReportPromptComponentPreview < ViewComponent::Preview
    def example
      render Commercial::ExceptionReportPromptComponent.new
    end
  end
end

# frozen_string_literal: true

module Forms
  class EmailReportButtonComponentPreview < ViewComponent::Preview
    def example(path: 'http://example.org', label: 'Test')
      render(Forms::EmailReportButtonComponent.new(path, label))
    end
  end
end

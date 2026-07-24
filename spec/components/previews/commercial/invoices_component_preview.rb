# frozen_string_literal: true

module Commercial
  class InvoicesComponentPreview < ViewComponent::Preview
    def example
      render Commercial::InvoicesComponent.new(invoices: ::Commercial::Invoice.by_date)
    end
  end
end

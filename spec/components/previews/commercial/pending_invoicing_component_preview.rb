# frozen_string_literal: true

module Commercial
  class PendingInvoicingComponentPreview < ViewComponent::Preview
    def example
      render Commercial::PendingInvoicingComponent.new(contracts:
          ::Commercial::Contract.pending_invoicing)
    end
  end
end

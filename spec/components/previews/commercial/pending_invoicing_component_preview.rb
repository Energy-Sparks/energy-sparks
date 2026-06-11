# frozen_string_literal: true

module Commercial
  class PendingInvoicingComponentPreview < ViewComponent::Preview
    def example
      render Commercial::PendingInvoicingComponent.new(contracts:
          ::Commercial::Contract.with_invoiced_contract_holders.pending_invoicing)
    end
  end
end

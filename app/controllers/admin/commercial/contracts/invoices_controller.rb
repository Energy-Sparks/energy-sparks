# frozen_string_literal: true

module Admin
  module Commercial
    module Contracts
      class InvoicesController < AdminController
        load_and_authorize_resource :contract, class: 'Commercial::Contract'
        def raise_invoice
          @licences = @contract.licences.pending_invoice.by_start_date
          @prices = ::Commercial::ContractPriceCalculator.new(@contract).per_school
        end

        def new
          # TODO: licences, nested changes
          @invoice = @contract.invoices.new(purchase_order_number: @contract.purchase_order_number)
        end
      end
    end
  end
end

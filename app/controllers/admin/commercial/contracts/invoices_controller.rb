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
          @prices = ::Commercial::ContractPriceCalculator.new(@contract).per_school
          @invoice = @contract.invoices.new(purchase_order_number: @contract.purchase_order_number)
          @contract.licences.where(id: licence_params).find_each do |licence|
            build_line_item(@invoice, licence, @prices[licence.school.id])
          end
        end

        def create
          @invoice = nil

          ::Commercial::Invoice.transaction do
            @invoice = ::Commercial::Invoice.create!(invoice_attributes.merge(created_by: current_user))

            @invoice.licences.each do |licence|
              licence.update!(status: :invoiced, updated_by: current_user)
            end
          end

          redirect_to admin_commercial_invoice_path(@invoice)
        rescue ActiveRecord::RecordInvalid
          redirect_to admin_commercial_contract_path(@contract), notice: 'Failed to create invoice'
        end

        private

        def build_line_item(invoice, licence, price)
          invoice.line_items.build(
            licence: licence,
            base_price: price.base_price,
            metering_fee: price.metering_fee,
            private_account_fee: price.private_account_fee,
            private_account: licence.school.data_sharing != 'public',
            number_of_meters: licence.school.meters.main_meter.active.count
          )
        end

        def licence_params
          params.require(:licences)
        end

        def invoice_attributes
          params.expect(
            commercial_invoice: [:contract_id,
                                 :purchase_order_number,
                                 {
                                   line_items_attributes: %i[
                                     base_price licence_id metering_fee
                                     number_of_meters private_account private_account_fee
                                   ]
                                 }]
          )
        end
      end
    end
  end
end

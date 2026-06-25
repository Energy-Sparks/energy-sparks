# frozen_string_literal: true

module Admin
  module Commercial
    module Contracts
      class InvoicesController < AdminController
        load_and_authorize_resource :contract, class: 'Commercial::Contract'
        def raise_invoice
          @licences = @contract.licences.includes(school: :school_group).pending_invoice.by_start_date
          @prices = ::Commercial::ContractPriceCalculator.new(@contract).per_school
        end

        def new
          @prices = ::Commercial::ContractPriceCalculator.new(@contract).per_school
          @invoice = @contract.invoices.new(purchase_order_number: @contract.purchase_order_number)
          @contract.licences.where(id: licence_params).find_each do |licence|
            build_line_item(@invoice, licence, @prices[licence.school.id][:price])
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

        def rounded_price(price)
          format('%.2f', price.round(2))
        end

        def build_line_item(invoice, licence, price)
          invoice.line_items.build(
            licence: licence,
            base_price: rounded_price(price.base_price),
            metering_fee: rounded_price(price.metering_fee),
            private_account_fee: rounded_price(price.private_account_fee),
            private_account: licence.school.data_sharing != 'public',
            number_of_meters: licence.school.meters.main_meter.active.count
          )
        end

        def licence_params
          params.require(:licences)
        end

        # rubocop:disable Rails/StrongParametersExpect
        def invoice_attributes
          params.require(:commercial_invoice).permit(
            :contract_id,
            :purchase_order_number,
            line_items_attributes: %i[base_price licence_id metering_fee number_of_meters private_account
                                      private_account_fee]
          )
        end
        # rubocop:enable Rails/StrongParametersExpect
      end
    end
  end
end

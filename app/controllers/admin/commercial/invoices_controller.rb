# frozen_string_literal: true

module Admin
  module Commercial
    class InvoicesController < AdminController
      load_and_authorize_resource :invoice, class: 'Commercial::Invoice'

      def index
        @invoices = ::Commercial::Invoice.by_date
      end

      def export
        invoices = ::Commercial::Invoice.where(id: invoice_params)
        send_data ::Commercial::XeroInvoiceExporter.new(invoices:).perform,
                  filename: EnergySparks::Filenames.csv('invoices')
      end

      private

      def invoice_params
        params.require(:invoices)
      end
    end
  end
end

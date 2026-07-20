# frozen_string_literal: true

module Admin
  module Commercial
    class InvoicesController < AdminController
      load_and_authorize_resource :invoice, class: 'Commercial::Invoice'

      def index
        @invoices = ::Commercial::Invoice.by_date

        respond_to do |format|
          format.html do
            render :index
          end
          format.csv do
            csv = export_summary? ? @invoices.to_csv : ::Commercial::LineItem.with_context.invoice_order.to_csv
            file_name = export_summary? ? 'invoices' : 'invoice-details'
            send_data csv, filename: EnergySparks::Filenames.csv(file_name)
          end
        end
      end

      def export
        invoices = ::Commercial::Invoice.where(id: invoice_params)
        send_data ::Commercial::XeroInvoiceExporter.new(invoices:).perform,
                  filename: EnergySparks::Filenames.csv('xero-invoices')
      end

      private

      def invoice_params
        params.require(:invoices)
      end

      def export_summary?
        export_params[:detail] == 'summary'
      end

      def export_params
        params.permit(:detail).with_defaults(detail: 'summary')
      end
    end
  end
end

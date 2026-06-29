# frozen_string_literal: true

module Commercial
  class XeroInvoiceExporter
    def initialize(invoices:)
      @invoices = invoices
    end

    def perform
      CSV.generate(headers: true) do |csv|
        csv << headers
        @invoices.each do |invoice|
          invoice_to_line_items(invoice).each do |row|
            csv << row
          end
        end
      end
    end

    private

    def headers
      %w[ContactName
         InvoiceNumber
         Reference
         InvoiceDate
         Description
         Quantity
         UnitAmount
         AccountCode
         TaxType]
    end

    def invoice_to_line_items(invoice)
      [[]]
    end
  end
end

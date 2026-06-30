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

    # contract holder name
    # invoice number
    # po number
    # invoice created date
    # description of line item, use template
    # quantity is always one
    # unit amount from fees
    # account code - Add AccountCode model
    #                Add AccountCode to contract and forms
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

    # One line item per school, with their fees and date ranges
    # One extra line item per extra fee with note, e.g. X meters
    def invoice_to_line_items(invoice)
      [[]]
    end
  end
end

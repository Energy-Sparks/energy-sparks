# frozen_string_literal: true

module Commercial
  class XeroInvoiceExporter
    TAX_TYPE = '20% (VAT on Income)'

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
      invoice_line_items = []
      invoice.line_items.each do |line_item|
        add_line_items(line_item)
      end
      invoice_line_items
    end

    def add_line_items(invoice_line_items, invoice, line_item)
      invoice_line_items << xero_line_item(invoice, line_item, 'TODO', line_item.base_price)

      if line_item.metering_fee.positive?
        invoice_line_items << xero_line_item(invoice, line_item, 'TODO',
                                             line_item.metering_fee)
      end

      return unless line_item.private_account_fee.positive?

      invoice_line_items << xero_line_item(invoice, line_item, 'TODO',
                                           line_item.private_account_fee)
    end

    def xero_line_item(invoice, description, amount)
      [
        invoice.contract.contract_holder.name,
        invoice.invoice_number,
        invoice.purchase_order_number,
        invoice.created_at.to_date.strftime('%d/%m/%Y'),
        description,
        1,
        amount,
        'TODO',
        TAX_TYPE
      ]
    end
  end
end

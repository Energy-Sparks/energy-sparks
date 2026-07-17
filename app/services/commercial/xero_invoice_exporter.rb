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

    def self.base_price_description(line_item)
      "Energy Sparks service fee for #{line_item.school.name} " \
        "#{line_item.licence.start_date.to_fs(:es_short)}-#{line_item.licence.end_date.to_fs(:es_short)}"
    end

    def self.metering_fee_description(line_item)
      "Analysis of data for #{line_item.number_of_meters} meters for #{line_item.school.name}"
    end

    def self.private_account_fee_description(line_item)
      "Private account fee for #{line_item.school.name}"
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

    # One line item per school, with their fees and date ranges
    # One extra line item per extra fee with note, e.g. X meters
    def invoice_to_line_items(invoice)
      invoice_line_items = []
      invoice.line_items.invoice_order.each do |line_item|
        add_base_price(invoice_line_items, invoice, line_item)
        add_metering_fee(invoice_line_items, invoice, line_item)
        add_private_account_fee(invoice_line_items, invoice, line_item)
      end
      invoice_line_items
    end

    def add_base_price(invoice_line_items, invoice, line_item)
      invoice_line_items << xero_line_item(invoice, self.class.base_price_description(line_item), line_item.base_price)
    end

    def add_metering_fee(invoice_line_items, invoice, line_item)
      return unless line_item.metering_fee.positive?

      invoice_line_items << xero_line_item(invoice, self.class.metering_fee_description(line_item),
                                           line_item.metering_fee)
    end

    def add_private_account_fee(invoice_line_items, invoice, line_item)
      return unless line_item.private_account_fee.positive?

      invoice_line_items << xero_line_item(invoice, self.class.private_account_fee_description(line_item),
                                           line_item.private_account_fee)
    end

    def xero_line_item(invoice, description, price)
      [
        invoice.contract.contract_holder.name,
        invoice.invoice_number,
        invoice.purchase_order_number,
        invoice.date.strftime('%d/%m/%Y'),
        description,
        1,
        rounded_price(price),
        invoice.contract.xero_account_code&.code,
        TAX_TYPE
      ]
    end

    def rounded_price(price)
      format('%.2f', price)
    end
  end
end

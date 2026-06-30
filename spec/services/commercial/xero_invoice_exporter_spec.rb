# frozen_string_literal: true

require 'rails_helper'

describe Commercial::XeroInvoiceExporter do
  let!(:invoice) { create(:commercial_invoice) }
  let!(:line_item) { create(:commercial_line_item, invoice:) }

  describe '#perform' do
    subject(:csv) { described_class.new(invoices: [invoice]).perform }

    context 'when producing headers' do
      subject(:headers) { CSV.parse(csv.lines[0]).first }

      it {
        expect(headers).to match_array(%w[ContactName
                                          InvoiceNumber
                                          Reference
                                          InvoiceDate
                                          Description
                                          Quantity
                                          UnitAmount
                                          AccountCode
                                          TaxType])
      }
    end

    context 'when producing invoice entry for line item without extra fees' do
      subject(:entry) { CSV.parse(csv.lines[1]).first }

      it 'adds the expected line item' do
        description = "Energy Sparks service fee for #{line_item.school.name} " \
                      "#{line_item.licence.start_date.to_fs(:es_short)}-#{line_item.licence.end_date.to_fs(:es_short)}"
        expect(entry).to eq([
                              invoice.contract.contract_holder.name,
                              invoice.invoice_number,
                              invoice.purchase_order_number,
                              invoice.date.strftime('%d/%m/%Y'),
                              description,
                              '1',
                              format('%.2f', line_item.base_price.round(2)),
                              invoice.contract.xero_account_code.code.to_s,
                              described_class::TAX_TYPE
                            ])
      end
    end
  end
end

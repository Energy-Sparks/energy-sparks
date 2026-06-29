# frozen_string_literal: true

require 'rails_helper'

describe Commercial::XeroInvoiceExporter do
  let!(:invoices) do
    [create(:commercial_invoice, :with_line_items)]
  end

  describe '#perform' do
    subject(:csv) { described_class.new(invoices: invoices).perform }

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

      it { expect(entry).not_to eq([]) }
    end
  end
end

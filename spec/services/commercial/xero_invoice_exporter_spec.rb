# frozen_string_literal: true

require 'rails_helper'

describe Commercial::XeroInvoiceExporter do
  let!(:invoice) { create(:commercial_invoice) }
  let!(:line_item) { create(:commercial_line_item, invoice:) }

  shared_examples 'it adds the base price to the invoice' do
    it 'adds the correctly described fee' do
      expect(entry).to eq([
                            invoice.contract.contract_holder.name,
                            invoice.invoice_number,
                            invoice.purchase_order_number,
                            invoice.date.strftime('%d/%m/%Y'),
                            described_class.base_price_description(line_item),
                            '1',
                            format('%.2f', line_item.base_price.round(2)),
                            invoice.contract.xero_account_code.code.to_s,
                            described_class::TAX_TYPE
                          ])
    end
  end

  shared_examples 'it adds the metering fee to the invoice' do
    it 'adds the correctly described fee' do
      expect(entry).to eq([
                            invoice.contract.contract_holder.name,
                            invoice.invoice_number,
                            invoice.purchase_order_number,
                            invoice.date.strftime('%d/%m/%Y'),
                            described_class.metering_fee_description(line_item),
                            '1',
                            format('%.2f', line_item.metering_fee.round(2)),
                            invoice.contract.xero_account_code.code.to_s,
                            described_class::TAX_TYPE
                          ])
    end
  end

  shared_examples 'it adds the private account fee to the invoice' do
    it 'adds the correctly described fee' do
      expect(entry).to eq([
                            invoice.contract.contract_holder.name,
                            invoice.invoice_number,
                            invoice.purchase_order_number,
                            invoice.date.strftime('%d/%m/%Y'),
                            described_class.private_account_fee_description(line_item),
                            '1',
                            format('%.2f', line_item.private_account_fee.round(2)),
                            invoice.contract.xero_account_code.code.to_s,
                            described_class::TAX_TYPE
                          ])
    end
  end

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
      subject(:entries) { CSV.parse(csv) }

      it { expect(csv.lines.length).to eq(2) }

      it_behaves_like 'it adds the base price to the invoice' do
        let(:entry) { entries[1] }
      end
    end

    context 'when producing invoice entry for line item with metering fees' do
      subject(:entries) { CSV.parse(csv) }

      let!(:line_item) { create(:commercial_line_item, invoice:, metering_fee: 25.0) }

      it { expect(csv.lines.length).to eq(3) }

      it_behaves_like 'it adds the base price to the invoice' do
        let(:entry) { entries[1] }
      end

      it_behaves_like 'it adds the metering fee to the invoice' do
        let(:entry) { entries[2] }
      end
    end

    context 'when producing invoice entry for line item with private acccount fees' do
      subject(:entries) { CSV.parse(csv) }

      let!(:line_item) { create(:commercial_line_item, invoice:, private_account_fee: 55.0) }

      it { expect(csv.lines.length).to eq(3) }

      it_behaves_like 'it adds the base price to the invoice' do
        let(:entry) { entries[1] }
      end

      it_behaves_like 'it adds the private account fee to the invoice' do
        let(:entry) { entries[2] }
      end
    end

    context 'when producing invoice entry for line item with all fees' do
      subject(:entries) { CSV.parse(csv) }

      let!(:line_item) { create(:commercial_line_item, invoice:, metering_fee: 25.0, private_account_fee: 55.0) }

      it { expect(csv.lines.length).to eq(4) }

      it_behaves_like 'it adds the base price to the invoice' do
        let(:entry) { entries[1] }
      end

      it_behaves_like 'it adds the metering fee to the invoice' do
        let(:entry) { entries[2] }
      end

      it_behaves_like 'it adds the private account fee to the invoice' do
        let(:entry) { entries[3] }
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Commercial::Invoice do
  describe 'when destroying' do
    let!(:invoice) { create(:commercial_invoice) }

    it 'does not allow invoice to be destroyed' do
      expect(invoice.destroy).to be(false)
    end

    context 'when contract is deletable' do
      let!(:contract) do
        create(:commercial_contract, contract_holder: create(:school, :archived, archived_date: 3.years.ago - 1.day))
      end
      let!(:invoice) { create(:commercial_invoice, contract:) }

      it 'allows invoice to be deleted' do
        expect { invoice.destroy }.to change(described_class, :count).by(-1)
      end
    end
  end

  describe '.invoice_number' do
    subject(:invoice) { create(:commercial_invoice) }

    it { expect(invoice.invoice_number).to eq("ES#{invoice.id.to_s.rjust(4, '0')}") }
  end

  describe '.to_csv' do
    subject(:csv) { CSV.parse(described_class.to_csv) }

    let!(:invoice) { create(:commercial_invoice) }

    it 'produces the expected headers' do
      expect(csv[0]).to eq([
                             'ID', 'Contract', 'Contract Holder', 'Created By', 'Date', 'Purchase Order Number',
                             'Base Price', 'Metering Fee', 'Private Account Fee', 'Total'
                           ])
    end

    it 'produces the expected rows' do
      expect(csv[1]).to eq([
                             invoice.invoice_number,
                             invoice.contract.name,
                             invoice.contract_holder.name,
                             invoice.created_by&.display_name,
                             invoice.date.iso8601,
                             invoice.purchase_order_number,
                             invoice.value.base_price.to_s,
                             invoice.value.metering_fee.to_s,
                             invoice.value.private_account_fee.to_s,
                             invoice.value.total.to_s
                           ])
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe Commercial::LineItem do
  it { is_expected.to validate_presence_of(:base_price) }
  it { is_expected.to validate_presence_of(:metering_fee) }
  it { is_expected.to validate_presence_of(:private_account_fee) }

  describe '.to_csv' do
    subject(:csv) { CSV.parse(described_class.to_csv) }

    let!(:invoice) { create(:commercial_invoice, :with_line_items) }

    it 'produces the expected headers' do
      expect(csv[0]).to eq(['ID', 'Contract', 'Contract Holder',
                            'Created By', 'Date', 'Purchase Order Number',
                            'School', 'Licence Id', 'Licence Start Date', 'Licence End Date',
                            'Private Account', 'Number of Meters',
                            'Base Price', 'Metering Fee', 'Private Account Fee', 'Total'])
    end

    it 'produces the expected rows' do # rubocop:disable RSpec/ExampleLength
      expect(csv[1]).to eq([
                             invoice.invoice_number,
                             invoice.contract.name,
                             invoice.contract_holder.name,
                             invoice.created_by&.display_name,
                             invoice.date.iso8601,
                             invoice.purchase_order_number,
                             invoice.line_items.first.school.name,
                             invoice.line_items.first.licence.id.to_s,
                             invoice.line_items.first.licence.start_date.iso8601,
                             invoice.line_items.first.licence.end_date.iso8601,
                             'false',
                             invoice.line_items.first.number_of_meters.to_s,
                             invoice.line_items.first.value.base_price.to_s,
                             invoice.line_items.first.value.metering_fee.to_s,
                             invoice.line_items.first.value.private_account_fee.to_s,
                             invoice.line_items.first.value.total.to_s
                           ])
    end
  end
end

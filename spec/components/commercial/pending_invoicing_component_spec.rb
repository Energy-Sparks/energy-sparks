# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::PendingInvoicingComponent, type: :component do
  let!(:contract) { create(:commercial_contract) }

  before do
    create_list(:commercial_licence, 3, contract:, status: :pending_invoice)
    create_list(:commercial_licence, 1, contract:, status: :invoiced)
    render_inline described_class.new(contracts: [contract])
  end

  it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
    let(:table_id) { '#pending-invoicing-table' }
    let(:expected_header) do
      [
        ['', 'Schools', ''],
        ['Name', 'Contract Holder', 'Start Date', 'To be invoiced', 'Invoiced', 'Licensed', 'Invoices', 'Actions']
      ]
    end
    let(:expected_rows) do
      [
        [
          contract.name,
          contract.contract_holder.name,
          contract.start_date.to_fs(:es_short),
          '3',
          '1',
          '4',
          '0',
          'Raise invoice'
        ]
      ]
    end
  end
end

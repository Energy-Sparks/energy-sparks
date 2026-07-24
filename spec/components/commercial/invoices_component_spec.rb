# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::InvoicesComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:invoice) { create(:commercial_invoice) }

  context 'when showing full details' do
    before do
      render_inline(described_class.new(invoices: [invoice]))
    end

    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { '#invoices-table' }
      let(:expected_header) do
        [
          ['', 'Number', 'Contract', 'Contract Holder', 'User', 'Date', 'Total']
        ]
      end
      let(:expected_rows) do
        [
          [
            '',
            invoice.invoice_number,
            invoice.contract.name,
            invoice.contract_holder.name,
            invoice.created_by.display_name,
            invoice.date.to_fs(:es_short),
            format_price(invoice.value.total)
          ]
        ]
      end
    end
  end
end

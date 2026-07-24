# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::LineItemsComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:invoice) { create(:commercial_invoice) }
  let!(:line_item) { create(:commercial_line_item, invoice:) }

  context 'when showing full details' do
    before do
      render_inline(described_class.new(invoice:))
    end

    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { "#invoice-#{invoice.id}-line-items-table" }
      let(:expected_header) do
        [
          ['School', 'Licence', 'Fees'],
          ['School Group', 'School', 'Private Account?', 'Number of Meters', 'Start date', 'End date',
           'Base price', 'Metering fee', 'Private account fee', 'Total']
        ]
      end
      let(:expected_rows) do
        [
          [
            '',
            line_item.school.name,
            'No',
            '0',
            line_item.licence.start_date.to_fs(:es_short),
            line_item.licence.end_date.to_fs(:es_short),
            format_price(line_item.value.base_price),
            format_price(line_item.value.metering_fee),
            format_price(line_item.value.private_account_fee),
            format_price(line_item.value.total)
          ]
        ]
      end
    end
  end
end

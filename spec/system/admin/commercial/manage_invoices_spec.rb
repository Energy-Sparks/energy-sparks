# frozen_string_literal: true

require 'rails_helper'

describe 'manage invoices', :include_application_helper do
  let(:user) { create(:admin) }

  before do
    sign_in(user)
    visit admin_commercial_path
  end

  context 'when viewing invoice lists' do
    let!(:invoice) { create(:commercial_invoice) }

    before { click_on 'All Invoices' }

    it { expect(page).to have_text('All Invoices') }

    it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
      let(:table_id) { '#invoices-table' }
      let(:expected_header) do
        [
          ['Number', 'Contract', 'Contract Holder', 'User', 'Date', 'Total']
        ]
      end
      let(:expected_rows) do
        [
          [
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

  context 'when viewing an invoice' do
    let!(:invoice) { create(:commercial_invoice) }
    let!(:line_item) { create(:commercial_line_item, invoice:) }

    before do
      click_on 'All Invoices'
      click_on invoice.invoice_number
    end

    context 'when viewing summary' do
      it { expect(page).to have_text(invoice.purchase_order_number) }
      it { expect(page).to have_text(invoice.date.to_fs(:es_short)) }
      it { expect(page).to have_link(invoice.created_by.display_name, href: user_path(invoice.created_by)) }

      it { expect(page).to have_link(invoice.contract.name, href: admin_commercial_contract_path(invoice.contract)) }

      it {
        expect(page).to have_link(invoice.contract_holder.name,
                                  href: polymorphic_path([:admin, invoice.contract_holder, :contracts]))
      }
    end

    context 'when viewing financial summary' do
      it 'shows the prices' do
        within('#financial-summary') do
          expect(page).to have_text(format_price(line_item.value.base_price))
          expect(page).to have_text(format_price(line_item.value.metering_fee))
          expect(page).to have_text(format_price(line_item.value.private_account_fee))
          expect(page).to have_text(format_price(line_item.value.total))
        end
      end
    end

    context 'when viewing line items' do
      it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
        let(:table_id) { "#invoice-#{invoice.id}-line-items-table" }
        let(:expected_header) do
          [
            ['School Group', 'School', 'Private Account?', 'Number of Meters',
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
end

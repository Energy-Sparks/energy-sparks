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

    it {
      expect(page).to have_link('Export summary to CSV',
                                href: admin_commercial_invoices_path(format: :csv, detail: :summary))
    }

    it {
      expect(page).to have_link('Export detail to CSV',
                                href: admin_commercial_invoices_path(format: :csv, detail: :full))
    }

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

    context 'when downloading for xero' do
      before do
        check "invoice_#{invoice.id}"
        click_on 'Export for xero', disabled: true # avoids enabling js, else can't access the response headers
      end

      it 'downloads a CSV' do
        expect(page.response_headers['Content-Type']).to eq 'text/csv'
        expect(page.response_headers['Content-Disposition']).to match(/energy-sparks-xero-invoices/)
      end
    end

    context 'when downloading summary CSV' do
      before do
        click_on 'Export summary to CSV'
      end

      it 'downloads a CSV' do
        expect(page.response_headers['Content-Type']).to eq 'text/csv'
        expect(page.response_headers['Content-Disposition']).to match(/energy-sparks-invoices/)
      end
    end

    context 'when downloading detail CSV' do
      before do
        click_on 'Export detail to CSV'
      end

      it 'downloads a CSV' do
        expect(page.response_headers['Content-Type']).to eq 'text/csv'
        expect(page.response_headers['Content-Disposition']).to match(/energy-sparks-invoice-details/)
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

    it { expect(page).to have_link('Pending Invoices', href: pending_invoicing_admin_commercial_contracts_path) }
    it { expect(page).to have_link('All Invoices', href: admin_commercial_invoices_path) }

    it {
      expect(page).to have_link('Xero export',
                                href: export_admin_commercial_invoices_path(params: { invoices: invoice.id }))
    }

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

    it { expect(page).to have_css('#metadata') }

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

  context 'with a pending invoice' do
    let!(:contract) { create(:commercial_contract) }
    let!(:licence) do
      create(:commercial_licence,
             contract:,
             status: :pending_invoice,
             school: create(:school, :with_school_group, number_of_pupils: 1))
    end

    before do
      click_on 'Pending invoicing'
    end

    it { expect(page).to have_css('div.commercial-pending-invoicing-component') }
    it { expect(page).to have_text(contract.name) }

    context 'when choosing to raise an invoice' do
      before { click_on 'Raise invoice' }

      it { expect(page).to have_text('Raise New Invoice') }

      it { expect(page).to have_link('edit the contract', href: edit_admin_commercial_contract_path(contract)) }

      it {
        expect(page).to have_link('manage all licences', href: edit_admin_commercial_contract_licences_path(contract))
      }

      it { expect(page).to have_text(contract.xero_account_code.display_label) }

      it_behaves_like 'it contains the expected data table', sortable: true, aligned: false do
        let(:table_id) { '#raise-invoice-table' }
        let(:expected_header) do
          [
            ['', '', 'School', 'Licence', ''],
            ['', 'Id', 'School Group', 'School', 'Data Status',
             'Start date', 'End date', 'Price', 'Actions']
          ]
        end
        let(:expected_rows) do
          [
            [
              '',
              "##{licence.id}",
              licence.school.school_group.name,
              licence.school.name,
              'No data',
              licence.start_date.to_fs(:es_short),
              licence.end_date.to_fs(:es_short),
              format_price(contract.product.small_school_price),
              'Edit'
            ]
          ]
        end
      end

      context 'when then proceeding', :js do
        before do
          check "licence_#{licence.id}"
          click_on 'Proceed'
        end

        it { expect(page).to have_text('Create Invoice') }
        it { expect(page).to have_text(contract.xero_account_code.display_label) }

        it 'populates the line item fields' do
          prefix = 'commercial_invoice[line_items_attributes][0]'
          expect(find("input[name=\"#{prefix}[number_of_meters]\"]").value).to eq('0')
          expect(find("input[name=\"#{prefix}[private_account]\"]").value).to eq('false')
          expect(find("input[name=\"#{prefix}[base_price]\"]").value).to eq('545.00')
          expect(find("input[name=\"#{prefix}[metering_fee]\"]").value).to eq('0.00')
          expect(find("input[name=\"#{prefix}[private_account_fee]\"]").value).to eq('0.00')
        end

        it_behaves_like 'it contains the expected data table', sortable: true, aligned: false, tfoot: true do
          let(:table_id) { '#line-items' }
          let(:expected_header) do
            [
              ['School', 'Number of Meters', 'Private Account?',
               'Base Price', 'Metering Fee', 'Private Account Fee', 'Total']
            ]
          end
          let(:expected_rows) do
            [
              [
                licence.school.name,
                '',
                '',
                '',
                '',
                '',
                '545.0'
              ]
            ]
          end
          let(:expected_footer_rows) do
            [
              ['', '', '', '545.0', '0.0', '0.0', '545.0']
            ]
          end
        end

        context 'when invoice is created' do # rubocop:disable RSpec/NestedGroups
          subject(:invoice) { licence.contract.invoices.first }

          before do
            fill_in 'Purchase order number', with: 'PO-98765'
            click_on 'Create invoice'
          end

          it 'creates the invoice and updates the licences' do
            expect(page).to have_text('Record summary')
            expect(page).to have_text(invoice.invoice_number)
            expect(page).to have_text('PO-98765')
            expect(licence.reload.status).to eq('invoiced')
          end
        end
      end
    end
  end
end

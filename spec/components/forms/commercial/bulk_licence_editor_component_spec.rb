# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Forms::Commercial::BulkLicenceEditorComponent, :include_application_helper, :include_url_helpers, type: :component do
  let(:id) { 'custom-id' }
  let(:classes) { 'extra-classes' }

  let!(:contract) { create(:commercial_contract) }
  let!(:licence) do
    create(:commercial_licence,
           contract:,
           school_specific_price: 100.0,
           invoice_reference: 'INV-001',
           comments: 'Some comments')
  end

  before do
    render_inline described_class.new(
      contract:,
      id: 'custom-id',
      classes: 'extra-classes')
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
    let(:html) { page }
  end

  def field_name(licence, name)
    "commercial_contract[licences_attributes][#{licence.id}][#{name}]"
  end

  context 'when rendering' do
    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false, rows: false do
      let(:table_id) { "##{contract.id}-licence-table" }
      let(:expected_header) do
        [
          ['Id', 'School', 'Start', 'End', 'Status', 'Price', 'Invoice Ref']
        ]
      end
    end

    context 'when populating the table' do
      context 'with the default form' do
        it 'generates the correct form action' do
          form = page.find("form#edit_commercial_contract_#{contract.id}")
          expect(form[:action]).to eq(admin_commercial_contract_licences_path(contract))
        end

        context 'when overriding the path' do
          before do
            render_inline described_class.new(
              contract:,
              form_path: '',
              id: 'custom-id',
              classes: 'extra-classes')
          end

          it 'generates the correct form action' do
            form = page.find("form#edit_commercial_contract_#{contract.id}")
            expect(form[:action]).to eq('')
          end
        end
      end

      context 'when rendering the main row' do
        subject(:main) { page.find("tr##{licence.id}-main-row") }

        it 'links to licence' do
          expect(main).to have_link("##{licence.id}", href: admin_commercial_licence_path(licence))
        end

        it 'links to school' do
          expect(main).to have_link(licence.school.name, href: school_path(licence.school))
        end

        it 'renders the date fields' do
          expect(main).to have_field(field_name(licence, :start_date),
                                     with: licence.start_date.strftime('%d/%m/%Y'))
          expect(main).to have_field(field_name(licence, :end_date),
                                     with: licence.end_date.strftime('%d/%m/%Y'))
        end

        it 'renders the status' do
          expect(main).to have_select(field_name(licence, :status),
                                      selected: licence.status.humanize)
        end

        it 'renders the price' do
          expect(main).to have_field(field_name(licence, :school_specific_price),
                                      with: '100.0')
        end

        it 'renders the invoice ref' do
          expect(main).to have_field(field_name(licence, :invoice_reference),
                                      with: 'INV-001')
        end
      end

      context 'when rendering the comments row' do
        subject(:comments) { page.find("tr##{licence.id}-comments-row") }

        it 'renders the comments' do
          expect(page).to have_field(field_name(licence, :comments),
                                      with: 'Some comments')
        end
      end
    end

    it 'has a submit button' do
      expect(page).to have_button('Save changes')
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::LicencesComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:contract) { create(:commercial_contract) }
  let!(:licence) { create(:commercial_licence, contract:, school: create(:school, :with_school_group)) }

  before do
    render_inline described_class.new(
      licences: Commercial::Licence.current,
      id: 'custom-id',
      classes: 'extra-classes',
      show_actions: false) do |c|
      c.with_header { 'Current Licences' }
    end
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
    let(:html) { page }
  end

  context 'when rendering' do
    it { expect(page).to have_content('Current Licences') }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#licences-table' }
      let(:expected_header) do
        [
          ['ID', 'School Group', 'School', 'Product', 'Contract', 'Start date', 'End date', 'Status']
        ]
      end
      let(:expected_rows) do
        [
          [
            "##{licence.id}",
            licence.school.school_group.name,
            licence.school.name,
            licence.contract.product.name,
            licence.contract.name,
            licence.start_date.iso8601,
            licence.end_date.iso8601,
            licence.status.to_s.humanize
          ]
        ]
      end
    end

    context 'when now showing contract information' do
      before do
        render_inline(described_class.new(
                        licences: Commercial::Licence.current,
                        id: 'custom-id',
                        classes: 'extra-classes',
                        show_actions: false,
                        show_contract: false
        ))
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#licences-table' }
        let(:expected_header) do
          [
            ['ID', 'School Group', 'School', 'Start date', 'End date', 'Status']
          ]
        end
        let(:expected_rows) do
          [
            [
              "##{licence.id}",
              licence.school.school_group.name,
              licence.school.name,
              licence.start_date.iso8601,
              licence.end_date.iso8601,
              licence.status.to_s.humanize
            ]
          ]
        end
      end
    end
  end
end

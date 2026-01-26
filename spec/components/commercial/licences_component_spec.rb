# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::LicencesComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:contract) { create(:commercial_contract) }
  let!(:licence) { create(:commercial_licence, contract:, school: create(:school, :with_school_group)) }
  let(:range) { :current }

  before do
    render_inline(described_class.new(
                    holder: contract,
                    range:,
                    id: 'custom-id',
                    classes: 'extra-classes',
                    show_actions: false
    ))
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
    let(:html) { page }
  end

  context 'when rendering current licences' do
    let!(:future_licence) { create(:commercial_licence, :future, contract:) }
    let!(:historical_licence) { create(:commercial_licence, :historical, contract:) }

    it { expect(page).not_to have_content(future_licence.school.name) }
    it { expect(page).not_to have_content(historical_licence.school.name) }
    it { expect(page).to have_content('Current Licences') }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#current-licences-table' }
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
  end
end

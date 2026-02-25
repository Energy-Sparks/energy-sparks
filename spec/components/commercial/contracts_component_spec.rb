# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::ContractsComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:contract_holder) { create(:funder) }
  let!(:contract) { create(:commercial_contract, contract_holder:) }
  let(:range) { :current }

  before do
    render_inline(described_class.new(
                    holder: contract_holder,
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

  context 'when rendering current contracts' do
    let!(:future_contract) { create(:commercial_contract, :future, contract_holder:) }
    let!(:historical_contract) { create(:commercial_contract, :historical, contract_holder:) }

    it { expect(page).not_to have_content(future_contract.name) }
    it { expect(page).not_to have_content(historical_contract.name) }
    it { expect(page).to have_content('Current Contracts') }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#current-contracts-table' }
      let(:expected_header) do
        [
          ['Name', 'Contract Holder', 'Product', 'Start Date', 'End Date', 'Number of Schools', 'Licensed Schools', 'Status']
        ]
      end
      let(:expected_rows) do
        [
          [
            contract.name,
            contract.contract_holder.name,
            contract.product.name,
            contract.start_date.iso8601,
            contract.end_date.iso8601,
            contract.number_of_schools.to_s,
            '0',
            contract.status.humanize
          ]
        ]
      end
    end
  end
end

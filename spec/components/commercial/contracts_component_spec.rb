# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::ContractsComponent, :include_application_helper, :include_url_helpers, type: :component do
  let!(:contract_holder) { create(:funder) }
  let!(:contract) { create(:commercial_contract, contract_holder:) }

  before do
    render_inline described_class.new(
      contracts: contract_holder.contracts.current,
      id: 'custom-id',
      classes: 'extra-classes',
      show_actions: false
    ) do |c|
      c.with_header { 'Current Contracts'}
    end
  end

  it_behaves_like 'an application component' do
    let(:expected_classes) { 'extra-classes' }
    let(:expected_id) { 'custom-id' }
    let(:html) { page }
  end

  context 'when rendering' do
    it { expect(page).to have_content('Current Contracts') }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#contracts-table' }
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

    context 'when not showing contract holder information' do
      before do
        render_inline described_class.new(
          contracts: contract_holder.contracts.current,
          id: 'custom-id',
          classes: 'extra-classes',
          show_actions: false,
          show_contract_holder: false
        )
      end

      it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
        let(:table_id) { '#contracts-table' }
        let(:expected_header) do
          [
            ['Name', 'Product', 'Start Date', 'End Date', 'Number of Schools', 'Licensed Schools', 'Status']
          ]
        end
        let(:expected_rows) do
          [
            [
              contract.name,
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
end

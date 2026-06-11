# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::ContractSchoolSummaryComponent, :include_application_helper, :include_url_helpers,
               type: :component do
  subject(:component) { described_class.new(contract:) }

  context 'with a School' do
    subject(:component) do
      described_class.new(contract: create(:commercial_contract, contract_holder: create(:school)))
    end

    it { expect(component.render?).to be(false) }
  end

  context 'with a Funder' do
    let!(:contract) { create(:commercial_contract, contract_holder: create(:funder)) }

    before do
      create(:commercial_licence, contract:, school: create(:school, data_enabled: false))
      3.times do
        create(:commercial_licence, contract:, school: create(:school, data_enabled: true))
      end
      create(:school_onboarding, contract:)
      render_inline component
    end

    it { expect(component.render?).to be(true) }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#contract-school-summary-table' }
      let(:expected_header) do
        [
          %w[Category Licensed]
        ]
      end
      let(:expected_rows) do
        [
          ['Visible', '4'],
          ['Data Visible', '3'],
          ['Onboarding', '1']
        ]
      end
    end
  end

  context 'with a School Group' do
    let(:school_group) { create(:school_group) }
    let!(:contract) { create(:commercial_contract, contract_holder: school_group) }

    before do
      create(:commercial_licence, contract:, school: create(:school, school_group:, data_enabled: false))
      3.times do
        create(:commercial_licence, contract:, school: create(:school, school_group:, data_enabled: true))
      end
      create(:school_onboarding, school_group:, contract:)

      create(:school_onboarding, school_group:)
      create(:school, school_group:, data_enabled: false)
      render_inline component
    end

    it { expect(component.render?).to be(true) }

    it_behaves_like 'it contains the expected data table', sortable: false, aligned: false do
      let(:table_id) { '#contract-school-summary-table' }
      let(:expected_header) do
        [
          ['Category', 'Licensed', 'In Group']
        ]
      end
      let(:expected_rows) do
        [
          ['Visible', '4', '5'],
          ['Data Visible', '3', '3'],
          ['Onboarding', '1', '2']
        ]
      end
    end
  end
end

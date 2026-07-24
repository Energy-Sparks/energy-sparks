#  frozen_string_literal: true

require 'rails_helper'

RSpec.describe Commercial::ExceptionReportPromptComponent, :include_url_helpers, type: :component do
  context 'when there is nothing to show' do
    before do
      render_inline described_class.new
    end

    it { expect(page).to have_no_css('div.commercial-exception-report-prompt-component') }
  end

  context 'when there are unlicensed schools' do
    before do
      create_list(:school, 2, :with_trust)
      render_inline described_class.new
    end

    it { expect(page).to have_text('There are currently 2 schools without licences.') }
    it { expect(page).to have_link('Unlicensed Schools', href: unlicensed_admin_commercial_licences_path) }
  end

  context 'when there are onboardings with no contracts' do
    before do
      create_list(:school_onboarding, 3, contract: nil)
      render_inline described_class.new
    end

    it { expect(page).to have_text('There are currently 3 incomplete onboardings') }
    it { expect(page).to have_link('Onboardings', href: admin_school_onboardings_path) }
  end

  context 'when there are overlapping licences' do
    before do
      licence = create(:commercial_licence)
      create(:commercial_licence, school: licence.school)
      render_inline described_class.new
    end

    it { expect(page).to have_text('There are currently 2 overlapping licences for the same school') }
    it { expect(page).to have_link('Overlapping Licences', href: overlapping_admin_commercial_licences_path) }
  end

  context 'when there are pending invoices' do
    before do
      contract = create(:commercial_contract, contract_holder: create(:funder, invoiced: true))
      create(:commercial_licence, contract:, status: :pending_invoice)
      render_inline described_class.new
    end

    it {
      expect(page).to have_text('There are 1 current contracts with pending invoices')
    }
  end
end

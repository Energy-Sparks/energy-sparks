# frozen_string_literal: true

require 'rails_helper'

describe 'group contracts and licences' do
  let(:school_group) { create(:school_group) }
  let!(:licence) { create(:commercial_licence, school: create(:school, :with_trust, group: school_group)) }

  before do
    calendar = create(:national_calendar, title: 'England and Wales')
    create(:academic_year, calendar:)
    sign_in(create(:admin))
    visit settings_school_group_path(school_group)
  end

  context 'when visiting licence summaries' do
    before { click_on 'Licence Summaries' }

    it { expect(page).to have_css('div.commercial-licensing-summary-component') }
    it { expect(page).to have_content(licence.school.name) }
    it { expect(page).to have_link('Licences', href: admin_school_licences_path(licence.school)) }
  end

  context 'when visiting contracts' do
    let!(:contract) { create(:commercial_contract, contract_holder: school_group) }

    before { click_on 'Contracts' }

    it { expect(page).to have_css('div.commercial-contracts-component') }
    it { expect(page).to have_content(contract.name) }
  end
end

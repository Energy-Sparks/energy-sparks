# frozen_string_literal: true

require 'rails_helper'

describe 'group contracts and licences' do
  let(:school_group) { create(:school_group) }
  let!(:licence) { create(:commercial_licence, school: create(:school, :with_trust, group: school_group)) }

  before do
    calendar = create(:national_calendar, title: 'England and Wales')
    academic_year = create(:academic_year, calendar:)
    create(:academic_year,
           calendar:,
           start_date: academic_year.end_date + 1.day,
           end_date: academic_year.end_date + 12.months)
    sign_in(create(:admin))
    visit settings_school_group_path(school_group)
  end

  context 'when visiting licence summaries' do
    before do
      within('#admin') do
        click_on 'Licence summaries'
      end
    end

    it { expect(page).to have_css('div.commercial-licensing-summary-component') }
    it { expect(page).to have_text(licence.school.name) }
    it { expect(page).to have_link('Licences', href: admin_school_licences_path(licence.school)) }

    it {
      expect(page).to have_link('Emailable summary',
                                href: admin_school_group_licence_summaries_path(school_group, format: :text))
    }
  end

  context 'when visiting contracts' do
    let!(:contract) { create(:commercial_contract, contract_holder: school_group) }

    before do
      within('#admin') do
        click_on 'Contracts'
      end
    end

    it { expect(page).to have_css('div.commercial-contracts-component') }
    it { expect(page).to have_text(contract.name) }
  end
end

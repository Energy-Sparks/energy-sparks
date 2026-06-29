# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'find school by name' do
  let(:admin) { create(:admin) }

  let!(:school) { create(:school, name: 'School', active: true, visible: true, data_enabled: true) }
  let!(:school_onboarding) { create(:school_onboarding, school_name: 'School name') }

  context 'when an admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Find school by name'
    end

    it 'displays the search page' do
      expect(page).to have_text('Find schools by name')
    end

    it 'does not display empty results message' do
      expect(page).to have_no_text('No schools were found with this name')
    end

    context 'when there are schools and onboardings' do
      before do
        fill_in 'query', with: 'School'
        click_on 'Search'
      end

      it 'shows schools' do
        expect(page).to have_link(school.name, href: school_path(school))
        expect(page).to have_text('Data Visible')
      end

      it 'shows onboardings' do
        expect(page).to have_link(school_onboarding.name, href: admin_school_onboardings_path)
      end
    end

    it 'reports empty results' do
      fill_in 'query', with: 'not a name'
      click_on 'Search'
      expect(page).to have_text('No schools were found with this name')
    end
  end
end

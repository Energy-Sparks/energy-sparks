# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'find school by urn' do
  let(:admin) { create(:admin) }

  let!(:school) { create(:school) }

  context 'when an admin' do
    before do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
      click_on 'Find school by URN'
    end

    it 'displays the search page' do
      expect(page).to have_content('Find schools by URN')
    end

    it 'finds a single meter' do
      fill_in 'query', with: school.urn
      click_on 'Search'

      expect(page).to have_content school.urn
      expect(page).to have_content school.name
    end

    it 'reports empty results' do
      fill_in 'query', with: '9999'
      click_on 'Search'
      expect(page).to have_content('No schools were found using this URN')
    end
  end
end

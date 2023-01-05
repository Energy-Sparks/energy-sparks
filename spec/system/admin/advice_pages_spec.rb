require 'rails_helper'

describe 'advice page management', type: :system do

  let(:school)        { create(:school) }
  let(:admin)         { create(:admin, school: school) }

  let!(:advice_page)   { create(:advice_page, key: 'baseload-summary') }

  describe 'managing' do

    before do
      sign_in(admin)
    end

    it 'allows the user to list and edit the advice pages' do
      visit admin_advice_pages_path

      expect(page).to have_content('Manage advice pages')
      expect(page).to have_content('baseload-summary')

      click_on 'Edit'

      expect(page).to have_content('Editing Advice Page: baseload-summary')

      fill_in_trix '#advice_page_learn_more_en', with: 'english text here'
      fill_in_trix '#advice_page_learn_more_cy', with: 'welsh text here'
      check 'Restricted'

      click_on 'Save'

      expect(page).to have_content('Advice Page updated')

      advice_page.reload
      expect(advice_page.restricted).to be_truthy
      expect(advice_page.learn_more.to_s).to include('english text here')
      expect(advice_page.learn_more_en.to_s).to include('english text here')
      expect(advice_page.learn_more_cy.to_s).to include('welsh text here')
    end
  end
end

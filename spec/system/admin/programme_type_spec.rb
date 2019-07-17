require 'rails_helper'

describe 'programme type management', type: :system do

  let!(:admin)  { create(:user, role: 'admin')}

  describe 'managing' do

    before do
      sign_in(admin)
      visit root_path
      click_on 'Programme Types'
    end

    it 'allows the user to create a programme type' do
      description = 'SPN1'
      old_title = 'Super programme number 1'
      new_title = 'Super programme number 2'
      click_on 'New Programme Type'
      fill_in 'Title', with: old_title
      fill_in 'Description', with: description
      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(old_title)
      expect(page).to have_content('Inactive')

      click_on 'Edit'
      fill_in 'Title', with: new_title
      check("Active", allow_label_click: true)
      click_on 'Save'
      expect(page).to have_content('Programme Types')
      expect(page).to have_content(new_title)
      expect(page).to have_content('Active')
      click_on new_title
      expect(page).to have_content(description)
      click_on 'All programme types'

      click_on 'Delete'
      expect(page).to have_content('There are no programme types')
    end
  end
end
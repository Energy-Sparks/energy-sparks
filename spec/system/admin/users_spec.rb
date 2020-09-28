require 'rails_helper'

describe 'Users', type: :system do
  let!(:admin)  { create(:admin) }

  describe 'managing' do

    before do
      sign_in(admin)
    end

    it 'offers roles, but excluding Guest' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Users'
      click_on 'New User'

      expect(page).to have_select(:user_role, with_options: ['Staff', 'Admin', 'School Admin'])
      expect(page).not_to have_select(:user_role, with_options: ['Guest'])
    end
  end
end


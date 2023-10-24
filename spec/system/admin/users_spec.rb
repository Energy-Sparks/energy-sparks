require 'rails_helper'

describe 'Users', type: :system do
  let!(:admin) { create(:admin) }

  describe 'searching for users' do
    before do
      sign_in(admin)
    end

    let!(:user) { create(:user, email: 'testing@example.com') }

    it 'provides a case insensitive search' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Users'

      expect(page.first('div#search_results')).not_to have_content('testing@example.com')
      expect(page.first('div#search_results')).not_to have_content('No users found')
      fill_in 'Email', with: 'testing@example.com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).not_to have_content('No users found')
      fill_in 'Email', with: 'test@example.com'
      click_on('Search')
      expect(page.first('div#search_results')).not_to have_content('testing@example.com')
      expect(page.first('div#search_results')).to have_content('No users found')
      fill_in 'Email', with: 'Testing@Example.Com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).not_to have_content('No users found')
      fill_in 'Email', with: 'Example.Com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).not_to have_content('No users found')
    end
  end

  describe 'managing users' do
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

    context 'when user exists with consent grant' do
      let!(:consent_grant)    { create(:consent_grant) }
      let!(:user)             { create(:user, consent_grants: [consent_grant]) }

      it 'can be deleted but keeps consent grant' do
        visit admin_users_path
        click_link "Delete", href: admin_user_path(user)
        expect(page).to have_content('User was successfully destroyed')
        expect(User.exists?(user.id)).to be_falsey
        expect(ConsentGrant.exists?(consent_grant.id)).to be_truthy
      end
    end
  end
end

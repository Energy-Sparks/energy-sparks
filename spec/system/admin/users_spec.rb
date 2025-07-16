# frozen_string_literal: true

require 'rails_helper'

describe 'Users' do
  include ActiveJob::TestHelper

  let!(:admin) { create(:admin) }

  before { sign_in(admin) }

  it 'accessible by menu' do
    visit root_path
    click_on 'Manage'
    click_on 'Admin'
    click_on 'Users'
    expect(page).to have_current_path(admin_users_path)
  end

  describe 'searching for users' do
    let!(:user) { create(:user, email: 'testing@example.com') }

    it 'provides a case insensitive search' do
      visit admin_users_path
      expect(page.first('div#search_results')).to have_no_content('testing@example.com')
      expect(page.first('div#search_results')).to have_no_content('No users found')
      fill_in 'Email', with: 'testing@example.com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).to have_no_content('No users found')
      fill_in 'Email', with: 'test@example.com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_no_content('testing@example.com')
      expect(page.first('div#search_results')).to have_content('No users found')
      fill_in 'Email', with: 'Testing@Example.Com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).to have_no_content('No users found')
      fill_in 'Email', with: 'Example.Com'
      click_on('Search')
      expect(page.first('div#search_results')).to have_content('testing@example.com')
      expect(page.first('div#search_results')).to have_no_content('No users found')
    end
  end

  describe 'managing users' do
    it 'creates a user' do
      visit admin_users_path
      click_on 'New User'
      fill_in 'Name', with: 'Random User'
      email = 'random_user2948@example.com'
      fill_in 'Email', with: email
      select 'Admin', from: 'user_role'
      click_on 'Create User'
      user = User.find_by(email:)
      expect(user.role).to eq('admin')
      expect(user.created_by).to eq(admin)
    end

    it 'offers roles, but excluding Guest' do
      visit admin_users_path
      click_on 'New User'
      expect(page).to have_select(:user_role, with_options: ['Staff', 'Admin', 'School Admin'])
      expect(page).to have_no_select(:user_role, with_options: ['Guest'])
    end

    context 'when user exists with consent grant' do
      let!(:consent_grant)    { create(:consent_grant) }
      let!(:user)             { create(:user, consent_grants: [consent_grant]) }

      it 'can be deleted but keeps consent grant' do
        visit admin_users_path
        click_link 'Delete', href: admin_user_path(user)
        expect(page).to have_content('User was successfully destroyed')
        expect(User).not_to exist(user.id)
        expect(ConsentGrant).to exist(consent_grant.id)
      end
    end

    it 'edits a user' do
      school = create(:school)
      visit admin_users_path
      click_on 'Edit'
      select school.name, from: 'school'
      click_on 'Update User'
      expect(page).to have_text('User was successfully updated.')
      expect(admin.cluster_schools).to eq([school])
      perform_enqueued_jobs
      expect(ActionMailer::Base.deliveries.length).to eq(1)
      expect(ActionMailer::Base.deliveries.last.subject).to eq("Welcome to the #{school.name} Energy Sparks account")
    end
  end
end

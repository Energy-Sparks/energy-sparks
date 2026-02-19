# frozen_string_literal: true

require 'rails_helper'

describe 'Administering users' do
  include ActiveJob::TestHelper

  let!(:admin) { create(:admin) }

  before { sign_in(admin) }

  describe 'visiting the users page' do
    it 'accessible by menu' do
      visit root_path
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Users'
      expect(page).to have_current_path(admin_users_path)
    end

    describe 'when searching' do
      let!(:user) { create(:user, email: 'testing@example.com') }

      before do
        visit admin_users_path
      end

      it { expect(page).to have_no_css('#search_results') }

      context 'with a search submitted' do
        let(:search) { '' }

        before do
          fill_in 'Email', with: search
          click_on 'Search'
        end

        context 'when there is an exact match' do
          let(:search) { 'testing@example.com' }

          it { expect(page.first('div#found-users')).to have_content('testing@example.com') }
          it { expect(page.first('div#search_results')).to have_no_content('No users found') }
        end

        context 'when there is no match' do
          let(:search) { 'test@example.com' }

          it { expect(page).to have_no_css('div#found-users') }
          it { expect(page.first('div#search_results')).to have_content('No users found') }
        end

        context 'when there is a case-insensitive match' do
          let(:search) { 'TESTING@example.com' }

          it { expect(page.first('div#found-users')).to have_content('testing@example.com') }
          it { expect(page.first('div#search_results')).to have_no_content('No users found') }
        end

        context 'when there is a match based on domain' do
          let(:search) { 'Example.com' }

          it { expect(page.first('div#found-users')).to have_content('testing@example.com') }
          it { expect(page.first('div#search_results')).to have_no_content('No users found') }
        end
      end
    end
  end

  describe 'managing users' do
    context 'when creating a new user' do
      let!(:school_group) { create(:school_group) }
      let!(:project_group) { create(:school_group, group_type: :project) }

      before do
        visit admin_users_path
        click_on 'New User'
      end

      it 'offers correct roles' do
        roles = ['Staff', 'Admin', 'School Admin', 'Group Admin', 'Group Manager', 'Pupil']
        expect(page).to have_select(:user_role, with_options: roles)
        expect(page).to have_no_select(:user_role, with_options: ['Guest'])
      end

      context 'when viewing the form', :js do
        it { expect(page).to have_select('School', visible: :hidden) }
        it { expect(page).to have_select('Staff role', visible: :hidden) }
      end

      context 'when selecting a Staff user', :js do
        before do
          select 'Staff', from: 'user_role'
        end

        it { expect(page).to have_select('School', visible: :visible) }
        it { expect(page).to have_select('Staff role', visible: :visible) }
      end

      context 'when selecting a School Admin', :js do
        before do
          select 'School Admin', from: 'user_role'
        end

        it { expect(page).to have_select('School', visible: :visible) }
        it { expect(page).to have_select('Staff role', visible: :visible) }

        it 'Shows the cluster school options' do
          expect(page).to have_select('Cluster schools', visible: :visible)
        end
      end

      context 'when selecting a Group Admin', :js do
        before do
          select 'Group Admin', from: 'user_role'
        end

        it { expect(page).to have_select('School', visible: :hidden) }
        it { expect(page).to have_select('Staff role', visible: :hidden) }

        it 'shows the organisation group options' do
          select_box = find('#school_group_select', visible: :all)
          option = select_box.find(:css, "option[value='#{school_group.id}']", visible: :all)
          expect(option[:hidden]).to eq('false')
        end

        it 'does not show the project group options' do
          select_box = find('#school_group_select', visible: :all)
          option = select_box.find(:css, "option[value='#{project_group.id}']", visible: :all)
          expect(option[:hidden]).to eq('true')
        end
      end

      context 'when selecting a Group Manager', :js do
        before do
          select 'Group Manager', from: 'user_role'
        end

        it { expect(page).to have_select('School', visible: :hidden) }
        it { expect(page).to have_select('Staff role', visible: :hidden) }

        it 'does not show the organisation group options' do
          select_box = find('#school_group_select', visible: :all)
          option = select_box.find(:css, "option[value='#{school_group.id}']", visible: :all)
          expect(option[:hidden]).to eq('true')
        end

        it 'shows the project group options' do
          select_box = find('#school_group_select', visible: :all)
          option = select_box.find(:css, "option[value='#{project_group.id}']", visible: :all)
          expect(option[:hidden]).to eq('false')
        end
      end

      context 'when completing the form' do
        subject(:user) { User.find_by(email:) }

        let(:email) { 'random_user2948@example.com' }

        before do
          fill_in 'Name', with: 'Random User'
          fill_in 'Email', with: email
          select 'Admin', from: 'Role'
          click_on 'Create User'
        end

        it { expect(user.role).to eq('admin') }
        it { expect(user.created_by).to eq(admin) }
      end
    end

    context 'when deleting a user' do
      let!(:user) { create(:user) }

      before do
        visit admin_users_path
        click_link 'Delete', href: admin_user_path(user)
      end

      it 'says the user is deleted' do
        expect(page).to have_content('User was successfully destroyed')
      end

      it 'deletes the user' do
        expect(User).not_to exist(user.id)
      end

      context 'when user exists with consent grant' do
        let!(:consent_grant)    { create(:consent_grant) }
        let!(:user)             { create(:user, consent_grants: [consent_grant]) }

        it 'says the user is deleted' do
          expect(page).to have_content('User was successfully destroyed')
        end

        it 'deletes the user' do
          expect(User).not_to exist(user.id)
        end

        it 'does not delete the ConsentGrant' do
          expect(ConsentGrant).to exist(consent_grant.id)
        end
      end

      context 'when user has created activities' do
        let!(:user) { activity.created_by }
        let!(:activity) { create(:activity, created_by: create(:user)) }

        it 'says the user is deleted' do
          expect(page).to have_content('User was successfully destroyed')
        end

        it 'deletes the user' do
          expect(User).not_to exist(user.id)
        end

        it 'does not delete the Activity' do
          expect(Activity).to exist(activity.id)
        end
      end
    end

    context 'when editing a user' do
      let!(:user) { create(:staff, name: 'Old name') }
      let!(:other_school) { create(:school) }

      before do
        Flipper.enable(:onboarding_mailer_2025)
        visit edit_admin_user_path(user)
      end

      context 'when updating user name' do
        before do
          fill_in 'Name', with: 'New name'
          click_on 'Update User'
        end

        it 'confirms the user is updated' do
          expect(page).to have_text('User was successfully updated.')
        end

        it 'saves the changes' do
          expect(user.reload.name).to eq('New name')
        end

        it 'does not send an email' do
          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.length).to eq(0)
        end
      end

      context 'when changing the school' do
        before do
          select other_school.name, from: 'School'
          click_on 'Update User'
        end

        it 'confirms the user is updated' do
          expect(page).to have_text('User was successfully updated.')
        end

        it 'saves the changes' do
          expect(user.reload.school).to eq(other_school)
        end

        it 'does send an email' do
          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.length).to eq(1)
          expect(ActionMailer::Base.deliveries.last.subject).to eq("Welcome to the #{other_school.name} Energy Sparks account")
        end
      end

      context 'when adding a cluster school' do
        before do
          select other_school.name, from: 'Cluster schools'
          select user.school.name, from: 'Cluster schools'
          click_on 'Update User'
        end

        it 'confirms the user is updated' do
          expect(page).to have_text('User was successfully updated.')
        end

        it 'saves the changes' do
          expect(user.reload.cluster_schools).to contain_exactly(user.school, other_school)
        end

        it 'does send an email' do
          perform_enqueued_jobs
          expect(ActionMailer::Base.deliveries.length).to eq(1)
          expect(ActionMailer::Base.deliveries.last.subject).to eq("Welcome to the #{other_school.name} Energy Sparks account")
        end
      end
    end
  end
end

require 'rails_helper'

RSpec.describe 'User profiles', :include_application_helper do
  let!(:user) { create(:school_admin) }

  shared_examples 'requires a login' do
    it { expect(page).to have_content('Sign in to Energy Sparks') }
  end

  shared_examples 'user is not authorised' do
    it { expect(page).to have_content('You are not authorized to access this page') }
  end

  shared_examples 'a profile page layout' do
    it { expect(page).to have_title(user.name) }

    it 'displays profile header' do
      expect(page).to have_css('#profile-header')
      within('#profile-header') do
        expect(page).to have_content(user.name)
      end
    end
  end

  shared_examples 'a profile page' do |group_admin: false, cluster_admin: false, school_user: true|
    it 'displays a basic profile summary' do
      expect(page).to have_css('#profile-summary')
      within('#profile-summary') do
        expect(page).to have_content(user.name)
        expect(page).to have_content(user.email)
        expect(page).to have_content(I18n.t("languages.#{user.preferred_locale}"))
        expect(page).to have_link(I18n.t('users.show.update_account'), href: edit_user_path(user))
        expect(page).to have_link(I18n.t('users.show.change_password'))
      end
    end

    it 'displays staff role', if: school_user || cluster_admin do
      within('#profile-summary') do
        expect(page).to have_content(user.staff_role.try(:translated_title))
      end
    end

    it 'displays links to manage emails', if: school_user || cluster_admin || group_admin do
      within('#my-schools-summary') do
        expect(page).to have_link(I18n.t('users.show.update_email_preferences'))
      end
    end

    it 'displays links to manage alerts', if: school_user || cluster_admin || group_admin do
      within('#my-schools-summary') do
        expect(page).to have_link(I18n.t('users.show.manage_alerts'))
      end
    end

    it 'displays summary of my schools', if: school_user do
      expect(page).to have_css('#my-schools-summary')
      within('#my-schools-summary') do
        expect(page.body).to include(I18n.t('users.show.school_summary.school_user_html', role: I18n.t("role.#{user.role}"), url: school_path(user.school), link_text: user.school.name))
      end
    end

    it 'displays summary of my schools', if: cluster_admin do
      expect(page).to have_css('#my-schools-summary')
      within('#my-schools-summary') do
        expect(page.body).to include(I18n.t('users.show.school_summary.cluster_admin_html', role: I18n.t("role.#{user.role}"), count: user.cluster_schools.count))
      end
    end

    it 'displays summary of my schools', if: group_admin do
      expect(page).to have_css('#my-schools-summary')
      within('#my-schools-summary') do
        expect(page.body).to include(I18n.t('users.show.school_summary.group_admin_html', role: I18n.t("role.#{user.role}"), count: user.school_group.schools.count, url: school_group_path(user.school_group), link_text: user.school_group.name))
      end
    end

    it 'displays a profile footer' do
      expect(page).to have_css('#profile-footer')
      within('#profile-footer') do
        expect(page).to have_content(I18n.t('users.show.joined', date: nice_date_times(user.confirmed_at)))
      end
    end
  end

  shared_examples 'a working account form' do |staff_role: true|
    context 'when form is displayed' do
      it 'has the expected fields' do
        expect(page).to have_field('Name', with: user.name)
        expect(page).to have_field('Email', with: user.email)
        expect(page).to have_select('Preferred language', selected: 'English')
      end

      it 'has a staff role field', if: staff_role do
        expect(page).to have_select('Role', selected: user.staff_role.translated_title)
      end

      it { expect(page).to have_link(I18n.t('common.labels.cancel', href: users_path(user))) }
    end

    context 'when updating' do
      it 'saves changes' do
        fill_in('Name', with: 'New name')
        fill_in('Email', with: 'updated@example.org')
        select('Welsh', from: 'Preferred language')
        click_on('Update')
        expect(page).to have_content('Account updated')
        expect(page).to have_css('#profile-summary')
        within('#profile-summary') do
          expect(page).to have_content('New name')
          expect(page).to have_content('updated@example.org')
          expect(page).to have_content('Welsh')
        end
      end
    end
  end

  shared_examples 'a working password form' do
    it { expect(page).to have_link(I18n.t('common.labels.cancel', href: users_path(user))) }
    it { expect(page).to have_content('12 characters minimum') }

    context 'when updating' do
      it 'saves password' do
        fill_in('Current password', with: user.password)
        fill_in('New password', with: 'thisismyupdatedpassword')
        fill_in('Confirm new password', with: 'thisismyupdatedpassword')
        click_on('Update')
        expect(page).to have_content('Password updated')
      end

      it 'rejects if password is wrong' do
        fill_in('Current password', with: 'this is wrong')
        fill_in('New password', with: 'thisismyupdatedpassword')
        fill_in('Confirm new password', with: 'thisismyupdatedpassword')
        click_on('Update')
        expect(page).not_to have_content('Password updated')
        expect(page).to have_content('Change password')
      end
    end
  end

  context 'when not logged in' do
    before do
      visit user_path(user)
    end

    it_behaves_like 'requires a login'
  end

  context 'when logged in' do
    context 'when viewing a different users profile' do
      let!(:signed_in_user) { create(:school_admin) }

      before do
        sign_in(signed_in_user)
        visit user_path(user)
      end

      it_behaves_like 'user is not authorised'

      context 'when I am a school admin from their school' do
        let!(:signed_in_user) { create(:school_admin, school: user.school) }

        it 'does not allow access'
      end
    end

    context 'with a pupil account' do
      it 'does not show link in navbar'
      it 'does not allow me to view my profile'
    end

    context 'with a school admin account' do
      before do
        sign_in(user)
      end

      context 'when viewing my account' do
        before { visit user_path(user) }

        it_behaves_like 'a profile page layout'
        it_behaves_like 'a profile page'
      end

      context 'when updating my account' do
        before do
          visit user_path(user)
          within('#profile-summary') do
            click_on('Update account')
          end
        end

        it_behaves_like 'a working account form'
      end

      context 'when updating my password' do
        before do
          visit user_path(user)
          within('#profile-summary') do
            click_on('Change password')
          end
        end

        it_behaves_like 'a working password form'
      end

      context 'when viewing my email preferences' do
        it 'show my preferences in Mailchimp'
        it 'allows me to update my preferences'
        it 'links to managing alerts'
      end

      context 'when viewing my schools' do
        it 'displays my schools'
        it 'allows me to update my alert preferences'
      end
    end

    context 'with a staff account' do
      let!(:user) { create(:staff) }

      before do
        sign_in(user)
      end

      context 'when viewing my profile' do
        before { visit user_path(user) }

        it_behaves_like 'a profile page layout'
        it_behaves_like 'a profile page'
      end

      context 'when updating my account' do
        before do
          visit user_path(user)
          click_on('Update account')
        end

        it_behaves_like 'a working account form'
      end
    end

    context 'with a cluster admin' do
      let!(:user) { create(:school_admin, :with_cluster_schools) }

      before do
        sign_in(user)
      end

      context 'when viewing my profile' do
        before { visit user_path(user) }

        it_behaves_like 'a profile page layout'
        it_behaves_like 'a profile page', cluster_admin: true, school_user: false
      end

      context 'when updating my account' do
        before do
          visit user_path(user)
          click_on('Update account')
        end

        it_behaves_like 'a working account form'
      end
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_active_schools)) }

      before do
        sign_in(user)
      end

      context 'when viewing my profile' do
        before { visit user_path(user) }

        it_behaves_like 'a profile page layout'
        it_behaves_like 'a profile page', group_admin: true, school_user: false
      end

      context 'when updating my account' do
        before do
          visit user_path(user)
          click_on('Update account')
        end

        it_behaves_like 'a working account form', staff_role: false
      end
    end

    context 'with an admin account' do
      let!(:user) { create(:admin) }

      before do
        sign_in(user)
      end

      context 'when viewing my profile' do
        before { visit user_path(user) }

        it_behaves_like 'a profile page layout'
        it_behaves_like 'a profile page', school_user: false
      end

      context 'when updating my account' do
        before do
          visit user_path(user)
          click_on('Update account')
        end

        it_behaves_like 'a working account form', staff_role: false
      end
    end
  end
end

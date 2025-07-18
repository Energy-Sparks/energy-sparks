require 'rails_helper'

RSpec.describe 'User account page and updates', :include_application_helper do
  let(:base) { '/r/school' }

  context 'when visiting a school redirect' do
    let(:path) { "#{base}/advice" }

    context 'without a session' do
      let!(:school) { create(:school, :with_school_group) }

      before do
        visit path
      end

      it_behaves_like 'the page requires a login'

      context 'with a successful adult login' do
        let!(:user) { create(:school_admin, password: 'thisismyuserpassword') }

        before do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          within '#staff' do
            click_on 'Sign in'
          end
        end

        it 'has redirected' do
          expect(page).to have_current_path school_advice_path(user.school), ignore_query: true
        end
      end

      context 'with a successful pupil login' do
        let!(:user) { create(:pupil, school: school, pupil_password: 'thisismyuserpassword') }
        let(:select_school) { "#{user.school.name} (#{user.school.school_group.name})" }

        before do
          within '#pupil' do
            select select_school, from: 'Select your school'
            fill_in 'Your pupil password', with: 'thisismyuserpassword'
            click_on 'Sign in'
          end
        end

        it 'has redirected' do
          expect(page).to have_current_path school_advice_path(user.school), ignore_query: true
        end
      end
    end

    context 'when logged in as a staff user' do
      let!(:user) { create(:staff) }

      before do
        sign_in(user)
        visit path
      end

      it 'has redirected' do
        expect(page).to have_current_path school_advice_path(user.school), ignore_query: true
      end

      context 'with dashboard redirect' do
        let(:path) { "#{base}/dashboard" }

        it 'has redirected' do
          expect(page).to have_current_path school_path(user.school), ignore_query: true
        end
      end

      context 'with pupil dashboard redirect' do
        let(:path) { "#{base}/pupils" }

        it 'has redirected' do
          expect(page).to have_current_path pupils_school_path(user.school), ignore_query: true
        end
      end
    end

    context 'when logged in as a school admin user' do
      let!(:user) { create(:school_admin) }

      before do
        sign_in(user)
        visit path
      end

      it 'has redirected' do
        expect(page).to have_current_path school_advice_path(user.school), ignore_query: true
      end
    end

    context 'when logged in as an admin' do
      let!(:user) { create(:admin) }
      let!(:school) { create(:school) }

      before do
        sign_in(user)
        visit path
      end

      it 'has redirected' do
        expect(page).to have_current_path school_advice_path(school), ignore_query: true
      end
    end

    context 'when logged in as a cluster admin user' do
      let!(:user) { create(:school_admin, :with_cluster_schools) }

      before do
        sign_in(user)
        visit path
      end

      it 'prompts user to choose' do
        expect(page).to have_content(I18n.t('redirects.choose_school.title'))
        expect(page).to have_content(I18n.t('redirects.choose_school.intro'))
        expect(page).to have_link(user.cluster_schools.first.name,
                                  href: school_advice_path(user.cluster_schools.first))
      end
    end

    context 'when logged in as a group admin user' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_active_schools)) }

      before do
        sign_in(user)
        visit path
      end

      it 'prompts user to choose' do
        expect(page).to have_content(I18n.t('redirects.choose_school.title'))
        expect(page).to have_content(I18n.t('redirects.choose_school.intro'))
        expect(page).to have_link(user.school_group.schools.first.name,
                                  href: school_advice_path(user.school_group.schools.first))
      end
    end
  end
end

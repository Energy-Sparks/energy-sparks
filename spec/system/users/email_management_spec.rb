require 'rails_helper'

RSpec.describe 'User email management', :include_application_helper do
  shared_examples 'an email preference page' do
    context 'when opted out' do
      it 'displays choices correctly'
    end

    context 'with existing preferences' do
      it 'displays them correctly'
    end

    context 'when not in Mailchimp' do
      it 'defaults form'
    end

    context 'when submitting preferences' do
      it 'updates Mailchimp correctly'
    end
  end

  context 'when logged in' do
    before do
      sign_in(user)
      visit user_path(user)
    end

    context 'with a school admin' do
      let(:user) { create(:school_admin) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.update_email_preferences'))
        end
      end

      it_behaves_like 'an email preference page'
    end

    context 'with a cluster admin' do
      let(:user) { create(:school_admin, :with_cluster_schools) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.update_email_preferences'))
        end
      end

      it_behaves_like 'an email preference page'
    end

    context 'with a group admin' do
      let!(:user) { create(:group_admin, school_group: create(:school_group, :with_active_schools)) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.update_email_preferences'))
        end
      end

      it_behaves_like 'an email preference page'
    end

    context 'with an admin' do
      let(:user) { create(:admin) }

      before do
        within('#profile-page-navigation') do
          click_on(I18n.t('users.show.update_email_preferences'))
        end
      end

      it_behaves_like 'an email preference page'

      context 'when viewing another user' do
        let(:school_admin) { create(:school_admin) }

        before do
          visit user_path(school_admin)
          within('#profile-page-navigation') do
            click_on(I18n.t('users.show.update_email_preferences'))
          end
        end

        it_behaves_like 'an email preference page' do
          let(:user) { school_admin }
        end
      end
    end
  end
end

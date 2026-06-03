require 'rails_helper'

RSpec.describe 'User email management', :include_application_helper do
  include_context 'with a stubbed audience manager'

  shared_examples 'an email preference page' do
    it do
      within('#email-preferences') do
        expect(page).to have_content(I18n.t('users.show.update_email_preferences'))
      end
    end

    context 'with existing preferences' do
      it 'displays them correctly' do
        expect(page).to have_checked_field('Getting the most out of Energy Sparks')
        expect(page).not_to have_checked_field('Engaging pupils in energy saving and climate')
        expect(page).not_to have_checked_field('Energy saving leadership')
        expect(page).not_to have_checked_field('Training opportunities')
        expect(page).not_to have_checked_field('Tailored advice and support')
      end
    end

    context 'when not in Mailchimp' do
      before do
        allow(audience_manager).to receive(:get_list_member).and_return(nil)
      end

      it 'some default options are pre-selected' do
        refresh
        expect(all('input[type=checkbox]').map(&:checked?)).not_to be_empty
      end
    end

    context 'when submitting preferences' do
      it 'updates Mailchimp correctly' do
        expect(audience_manager).to receive(:subscribe_or_update_contact) do |contact, kwargs|
          expect(contact.interests.values).to eq([true, true, false, false, false])
          expect(kwargs[:status]).to eq('subscribed')
        end
        check('Engaging pupils in energy saving and climate')
        within('#mailchimp-form') do
          click_on('Update')
        end
        expect(page).to have_content(I18n.t('users.emails.update.updated'))
      end
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

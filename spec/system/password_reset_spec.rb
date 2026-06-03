require 'rails_helper'

describe 'User password reset' do
  context 'when requesting a password reset' do
    around do |example|
      ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
        example.run
      end
    end

    let!(:user)             { create(:user, preferred_locale: preferred_locale) }
    let(:email)             { ActionMailer::Base.deliveries.last }

    before do
      visit new_user_session_path
      click_on I18n.t('devise.shared.links.forgot_your_password')
      fill_in 'user_email', with: user.email
      click_on I18n.t('devise.passwords.new.send_me_reset_password_instructions')
      open_email user.email
    end

    context 'with a preference for English' do
      let(:preferred_locale) { :en }

      it 'has text in english' do
        expect(current_email).to have_content(I18n.t('devise.mailer.reset_password_instructions.energy_sparks_password_reset'))
      end

      it 'email links to non-locale specific site' do
        expect(current_email.html_part.decoded).to include('http://localhost/users/password/edit?reset_password_token=')
      end
    end

    context 'with a preference for Welsh' do
      let(:preferred_locale) { :cy }

      it 'has text in Welsh' do
        expect(email).to have_content(I18n.t('devise.mailer.reset_password_instructions.energy_sparks_password_reset', locale: :cy))
      end

      it 'emails link to locale specific site' do
        expect(email.html_part.decoded).to include('http://cy.localhost/users/password/edit?reset_password_token=')
      end
    end
  end

  context 'when resetting password for an existing user' do
    let(:valid_password) { 'valid password' }

    include_context 'with a stubbed audience manager'

    let(:user) { create(:staff) }

    before do
      visit new_user_session_path
      click_on I18n.t('devise.shared.links.forgot_your_password')
      fill_in 'user_email', with: user.email
      click_on I18n.t('devise.passwords.new.send_me_reset_password_instructions')
      open_email user.email
      current_email.click_link I18n.t('devise.mailer.reset_password_instructions.change_my_password')
    end

    it { expect(page).to have_content('Set your password') }

    it 'does not show checkboxes for alerts' do
      expect(page).not_to have_content('Energy Sparks alerts:')
    end

    it 'does not show checkboxes for newsletter' do
      expect(page).not_to have_content(I18n.t('mailchimp_signups.mailchimp_form.email_preferences'))
    end

    context 'with valid password and confirmation' do
      before do
        fill_in :user_password, with: valid_password
        fill_in :user_password_confirmation, with: valid_password
        click_button 'Set my password'
      end

      it { expect(page).to have_content('Your password has been changed successfully') }
    end
  end
end

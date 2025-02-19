require 'rails_helper'

describe 'password reset' do
  let(:preferred_locale)  { }
  let!(:user)             { create(:user, preferred_locale: preferred_locale) }
  let(:email)             { ActionMailer::Base.deliveries.last }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
        example.run
      end
    end
  end

  context 'when using default domain' do
    before do
      visit new_user_session_path
      click_link 'Forgot your password'
      fill_in 'user_email', with: user.email
      click_button 'Send me reset password instructions'
    end

    context 'preferred locale is en' do
      let(:preferred_locale) { :en }

      it 'links to non-locale specific site' do
        expect(email.html_part.decoded).to include('http://localhost/users/password/edit?reset_password_token=')
      end
    end

    context 'preferred locale is cy' do
      let(:preferred_locale) { :cy }

      it 'links to locale specific site' do
        expect(email.html_part.decoded).to include('http://cy.localhost/users/password/edit?reset_password_token=')
      end
    end
  end
end

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
    before :each do
      visit new_user_session_path
      click_link 'Forgot your password'
      fill_in "user_email", with: user.email
      click_button 'Send me reset password instructions'
    end

    context 'preferred locale is en' do
      let(:preferred_locale) { :en }
      it 'links to non-locale specific site' do
        expect(email.body).to include("http://localhost/users/password/edit?reset_password_token=")
      end
    end

    context 'preferred locale is cy' do
      let(:preferred_locale) { :cy }
      it 'links to locale specific site' do
        expect(email.body).to include("http://cy.localhost/users/password/edit?reset_password_token=")
      end
    end

    context 'with locale redirects' do
      let(:preferred_locale) { :cy }
      it 'shows locale selector' do
        expect(user.reload.preferred_locale).to eq("cy")
        urls = URI.extract(email.body.to_s, ['http'])
        visit urls.last
        expect(page).to have_content('Preferred language')
        fill_in "New password", with: "password"
        fill_in "Confirm new password", with: "password"
        select "English", from: "Preferred language"
        click_button "Set my password"
        expect(user.reload.preferred_locale).to eq("en")
      end
    end
  end
end

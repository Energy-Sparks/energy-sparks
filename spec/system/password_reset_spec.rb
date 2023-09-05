require 'rails_helper'

describe 'password reset' do

  let!(:user) { create(:user, preferred_locale: :cy) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: enable_locale_emails do
        ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
          example.run
        end
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

    context 'with locales not enabled' do
      let(:enable_locale_emails) { 'false' }
      it 'links to non-locale specific site' do
        email = ActionMailer::Base.deliveries.last
        expect(email.body).to include("http://localhost/users/password/edit?reset_password_token=")
      end
    end

    context 'with locales enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'links to non-locale specific site' do
        email = ActionMailer::Base.deliveries.last
        expect(email.body).to include("http://cy.localhost/users/password/edit?reset_password_token=")
      end
    end

    context 'with locale redirects and email locales enabled' do
      let(:enable_locale_emails) { 'true' }
      it 'shows locale selector' do
        expect(user.reload.preferred_locale).to eq("cy")
        email = ActionMailer::Base.deliveries.last
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

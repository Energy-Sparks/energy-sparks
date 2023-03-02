require 'rails_helper'

RSpec.describe EnergySparksDeviseMailer do

  let(:school)                { create(:school) }
  let(:user)                  { create(:user, school: school) }
  let(:enable_locale_emails)  { 'true' }

  around do |example|
    ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: enable_locale_emails do
      ClimateControl.modify WELSH_APPLICATION_HOST: 'cy.localhost' do
        example.run
      end
    end
  end

  describe '#confirmation_instructions' do
    before :each do
      school.update(country: country)
      user.send_confirmation_instructions
      expect(ActionMailer::Base.deliveries.count).to eql 1
      @email = ActionMailer::Base.deliveries.last
    end
    context 'when school has country of england' do
      let(:country) { "england" }
      it 'sends an email in en' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account")
      end
      it 'contains links to default site but not cy site' do
        expect(@email.body.to_s).to include("http://localhost/users/confirmation?confirmation_token=")
        expect(@email.body.to_s).not_to include("http://cy.localhost/users/confirmation?confirmation_token=")
      end
    end

    context 'when school has country of wales' do
      let(:country) { "wales" }
      it 'sends an email in en and cy' do
        expect(@email.subject).to eq("Energy Sparks: confirm your account / Sbarcynni: cadarnhau eich cyfrif")
      end
      it 'contains links to default site and cy site' do
        expect(@email.body.to_s).to include("http://localhost/users/confirmation?confirmation_token=")
        expect(@email.body.to_s).to include("http://cy.localhost/users/confirmation?confirmation_token=")
      end
      context 'but locale emails are turned off' do
        let(:enable_locale_emails)  { 'false' }
        it 'sends an email in en only' do
          expect(@email.subject).to eq("Energy Sparks: confirm your account")
        end
      end
    end
  end
end

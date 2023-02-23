require 'rails_helper'

RSpec.describe ConsentGrantMailer do

  let(:user) { create(:user, preferred_locale: :cy) }
  let(:school) { create(:school, name: 'Test School') }
  let(:consent_grant) { create(:consent_grant, user: user, school: school) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: enable_locale_emails do
        example.run
      end
    end
  end

  before :each do
    ConsentGrantMailer.with_user_locales(users: [user], consent_grant: consent_grant) { |mailer| mailer.email_consent.deliver_now }
    @email = ActionMailer::Base.deliveries.last
  end

  context 'when locale emails disabled' do
    let(:enable_locale_emails) { 'false' }
    describe '#email_consent' do
      it 'sends an email with en strings' do
        expect(@email.subject).to eql ("Your grant of consent to Energy Sparks")
        expect(@email.body.to_s).to include("Thank you for granting permission for Energy Sparks to access data for Test School")
      end
    end
  end

  context 'when locale emails enabled' do
    let(:enable_locale_emails) { 'true' }
    describe '#email_consent' do
      it 'sends an email with cy strings' do
        expect(@email.subject).to eql ("Eich caniatâd i Sbarcynni")
        expect(ActionController::Base.helpers.sanitize(@email.body.to_s)).to include("Diolch am roi caniatâd i Sbarcynni gael mynediad at ddata ar gyfer Test School")
      end
    end
  end
end

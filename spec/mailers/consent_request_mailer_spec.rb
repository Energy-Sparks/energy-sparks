require 'rails_helper'

RSpec.describe ConsentRequestMailer do

  let(:user) { create(:user, preferred_locale: :cy) }
  let(:school) { create(:school, name: 'Test School') }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: enable_locale_emails do
        example.run
      end
    end
  end

  before :each do
    ConsentRequestMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.request_consent.deliver_now }
    @email = ActionMailer::Base.deliveries.last
  end

  context 'when locale emails disabled' do
    let(:enable_locale_emails) { 'false' }
    describe '#request_consent' do
      it 'sends an email with en strings' do
        expect(@email.subject).to eql ("We need permission to access your school's energy data")
        expect(@email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
      end
    end
  end

  context 'when locale emails enabled' do
    let(:enable_locale_emails) { 'true' }
    describe '#request_consent' do
      it 'sends an email with cy strings' do
        expect(@email.subject).to eql I18n.t('consent_request_mailer.request_consent.subject', locale: :cy)
        expect(ActionController::Base.helpers.sanitize(@email.body.to_s)).to include(I18n.t('consent_request_mailer.request_consent.description', school_name: 'Test School', locale: :cy))
      end
    end
  end
end

require 'rails_helper'

RSpec.describe ConsentRequestMailer do
  let(:user)    { create(:user, preferred_locale: preferred_locale) }
  let(:school)  { create(:school, name: 'Test School') }
  let(:email)   { ActionMailer::Base.deliveries.last }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      example.run
    end
  end

  before do
    ConsentRequestMailer.with_user_locales(users: [user], school: school) { |mailer| mailer.request_consent.deliver_now }
  end

  describe '#request_consent' do
    context 'user locale is :en' do
      let(:preferred_locale) { :en }

      it 'sends an email with en strings' do
        expect(email.subject).to eql("We need permission to access your school's energy data")
        expect(email.body.to_s).to include('Please provide permission for Energy Sparks to access data for Test School')
      end
    end

    context 'user locale is :cy' do
      let(:preferred_locale) { :cy }

      it 'sends an email with cy strings' do
        expect(email.subject).to eql I18n.t('consent_request_mailer.request_consent.subject', locale: :cy)
        expect(ActionController::Base.helpers.sanitize(email.body.to_s)).to include(I18n.t('consent_request_mailer.request_consent.description', school_name: 'Test School', locale: :cy))
      end
    end
  end
end

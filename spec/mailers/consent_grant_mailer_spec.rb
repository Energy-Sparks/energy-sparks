require 'rails_helper'

RSpec.describe ConsentGrantMailer do
  let(:user)          { create(:user, preferred_locale: preferred_locale) }
  let(:school)        { create(:school, name: 'Test School') }
  let(:consent_grant) { create(:consent_grant, user: user, school: school) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      example.run
    end
  end

  before do
    ConsentGrantMailer.with_user_locales(users: [user], consent_grant: consent_grant) { |mailer| mailer.email_consent.deliver_now }
    @email = ActionMailer::Base.deliveries.last
  end

  describe '#email_consent' do
    context 'preferred locale is :en' do
      let(:preferred_locale) { :en }

      it 'sends an email with en strings' do
        expect(@email.subject).to eql('Your grant of consent to Energy Sparks')
        expect(@email.body.to_s).to include('Thank you for granting permission for Energy Sparks to access data for Test School')
      end
    end

    context 'preferred locale is :cy' do
      let(:preferred_locale) { :cy }

      it 'sends an email with cy strings' do
        expect(@email.subject).to eql('Eich caniatâd i Sbarcynni')
        expect(ActionController::Base.helpers.sanitize(@email.body.to_s)).to include('Diolch am roi caniatâd i Sbarcynni gael mynediad at ddata ar gyfer Test School')
      end
    end
  end
end

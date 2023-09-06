require 'rails_helper'

RSpec.describe ConsentGrantMailer do

  let(:user) { create(:user, preferred_locale: :cy) }
  let(:school) { create(:school, name: 'Test School') }
  let(:consent_grant) { create(:consent_grant, user: user, school: school) }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
      example.run
    end
  end

  before :each do
    ConsentGrantMailer.with_user_locales(users: [user], consent_grant: consent_grant) { |mailer| mailer.email_consent.deliver_now }
    @email = ActionMailer::Base.deliveries.last
  end

  describe '#email_consent' do
    it 'sends an email with cy strings' do
      expect(@email.subject).to eql ("Eich caniatâd i Sbarcynni")
      expect(ActionController::Base.helpers.sanitize(@email.body.to_s)).to include("Diolch am roi caniatâd i Sbarcynni gael mynediad at ddata ar gyfer Test School")
    end
  end
end

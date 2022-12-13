require 'rails_helper'

RSpec.describe ConsentGrantMailer do

  let(:user) { create(:user) }
  let(:school) { create(:school, name: 'Test School') }
  let(:consent_grant) { create(:consent_grant, user: user, school: school) }

  describe '#email_consent' do

    context 'when locale is cy' do

      let(:cy_translations) do
        {
          consent_grant_mailer:
            {
              email_consent:
                {
                  subject: "Welsh subject line should not be used (yet)",
                  message_1: "Welsh message_1 for %{school_name} should not be used (yet)"
                }
            }
        }
      end

      before do
        I18n.locale = 'cy'
        I18n.backend.store_translations("cy", cy_translations)
      end

      after do
        I18n.locale = 'en'
      end

      it 'sends an email with en strings even if I18n is cy' do
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          ConsentGrantMailer.with(consent_grant: consent_grant).email_consent.deliver_now
        end
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eql ("Your grant of consent to Energy Sparks")
        expect(email.body.to_s).to include("Thank you for granting permission for Energy Sparks to access data for Test School")
      end
    end
  end
end

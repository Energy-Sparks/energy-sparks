require 'rails_helper'

RSpec.describe ConsentRequestMailer do

  let(:school) { create(:school, name: 'Test School') }
  let(:email_address) { 'blah@blah.com' }

  describe '#request_consent' do

    context 'when locale is cy' do

      let(:cy_translations) do
        {
          consent_request_mailer:
            {
              request_consent:
                {
                  subject: "Welsh subject line should not be used (yet)",
                  description: "Welsh description for %{school_name} should not be used (yet)"
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
          ConsentRequestMailer.with(emails: [email_address], school: school).request_consent.deliver_now
        end
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eql ("We need permission to access your school's energy data")
        expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
      end
    end
  end
end

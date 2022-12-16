require 'rails_helper'

RSpec.describe ConsentRequestMailer do

  let(:school)        { create(:school, name: 'Test School') }
  let(:user)          { create(:user, school: school, email: 'en@example.com') }

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

      around do |example|
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          example.run
        end
      end

      it 'sends an email with en strings even if I18n is cy' do
        ConsentRequestMailer.with(users: [user], school: school).request_consent.deliver_now
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eql ("We need permission to access your school's energy data")
        expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
      end

      context 'when emails are sent with preferred locale' do
        let(:user_cy) { create(:user, school: school, email: 'cy@example.com') }

        it 'sends an email with cy strings if user preference is cy' do

          expect(user_cy).to receive(:preferred_locale).at_least(:once).and_return(:cy)

          ConsentRequestMailer.with(users: [user, user_cy], school: school).request_consent.deliver_now

          expect(ActionMailer::Base.deliveries.count).to eq(2)
          email = ActionMailer::Base.deliveries.first
          expect(email.subject).to eql ("We need permission to access your school's energy data")
          expect(email.body.to_s).to include("Please provide permission for Energy Sparks to access data for Test School")
          email = ActionMailer::Base.deliveries.last
          expect(email.subject).to eql ("Welsh subject line should not be used (yet)")
          expect(email.body.to_s).to include("Welsh description for Test School should not be used (yet)")
        end
      end
    end
  end
end

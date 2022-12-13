require 'rails_helper'

RSpec.describe BillRequestMailer do

  let(:school) { create(:school, name: 'Test School') }
  let(:electricity_meter) { create(:electricity_meter) }
  let(:gas_meter) { create(:gas_meter) }

  describe '#email_consent' do

    context 'when locale is cy' do

      let(:cy_translations) do
        {
          bill_request_mailer:
            {
              request_bill:
                {
                  subject: "Welsh subject line should not be used (yet)",
                  description: "Welsh description should not be used (yet)",
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
          BillRequestMailer.with(emails: ['test@blah.com'], school: school, electricity_meters: [electricity_meter], gas_meters: [gas_meter]).request_bill.deliver_now
        end
        email = ActionMailer::Base.deliveries.last
        expect(email.subject).to eql ("Please upload a recent energy bill to Energy Sparks")
        expect(email.body.to_s).to include("Please upload an energy bill for Test School")
      end
    end
  end
end

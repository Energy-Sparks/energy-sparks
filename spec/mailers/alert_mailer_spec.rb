require 'rails_helper'

RSpec.describe AlertMailer do

  let(:school) { create(:school) }
  let(:email_address) { 'blah@blah.com' }

  describe '#alert_email' do
    it 'sends an email with mailgun tag in header' do
      AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
      expect(ActionMailer::Base.deliveries.count).to eql 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql "Energy Sparks alerts"
      expect(email.mailgun_headers['X-Mailgun-Tag']).to eql "alerts"
    end

    it 'does not send an email if env var is set to suppress' do
      ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
        expect(ActionMailer::Base.deliveries.count).to eql 0
      end
    end
  end
end

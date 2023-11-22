require 'rails_helper'

RSpec.describe AlertMailer do
  let(:school)                { create(:school) }
  let(:email_address)         { 'blah@blah.com' }
  let(:email)                 { ActionMailer::Base.deliveries.last }
  let(:send_automated_emails) { 'true' }

  around do |example|
    ClimateControl.modify SEND_AUTOMATED_EMAILS: send_automated_emails do
      example.run
    end
  end

  describe '#alert_email' do
    it 'sends an email with mailgun tag in header' do
      AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
      expect(ActionMailer::Base.deliveries.count).to be 1
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :en)
      expect(email.mailgun_headers['X-Mailgun-Tag']).to eql "alerts"
    end

    it 'uses locale if specified' do
      AlertMailer.with(email_address: email_address, school: school, events: [], locale: :cy).alert_email.deliver_now
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :cy)
    end

    it 'uses default locale' do
      AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :en)
    end

    context "SEND_AUTOMATED_EMAILS env var is false" do
      let(:send_automated_emails) { 'false' }

      it 'does not send an email' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
        expect(ActionMailer::Base.deliveries.count).to be 0
      end
    end
  end

  describe '#with_contact_locale' do
    let(:user) { create(:user, preferred_locale: :cy) }
    let(:contact) { create(:contact_with_name_email, school: school, user: user) }

    it 'uses locale from contact' do
      AlertMailer.with_contact_locale(contact: contact, events: []) { |mailer| mailer.alert_email.deliver_now }
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :cy)
    end
  end
end

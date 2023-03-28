require 'rails_helper'

RSpec.describe AlertMailer do

  let(:school) { create(:school) }
  let(:email_address) { 'blah@blah.com' }

  describe '#alert_email' do
    it 'sends an email with mailgun tag in header' do
      ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
      end
      expect(ActionMailer::Base.deliveries.count).to eql 1
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :en)
      expect(email.mailgun_headers['X-Mailgun-Tag']).to eql "alerts"
    end

    it 'does not send an email if env var is not set' do
      ClimateControl.modify SEND_AUTOMATED_EMAILS: 'false' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
      end
      expect(ActionMailer::Base.deliveries.count).to eql 0
    end

    it 'uses locale if specified and enabled' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: 'true' do
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          AlertMailer.with(email_address: email_address, school: school, events: [], locale: :cy).alert_email.deliver_now
        end
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :cy)
    end

    it 'uses default locale if specified but disabled' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: 'false' do
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          AlertMailer.with(email_address: email_address, school: school, events: [], locale: :cy).alert_email.deliver_now
        end
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :en)
    end
  end

  describe '#with_contact_locale' do
    let(:user) { create(:user, preferred_locale: :cy) }
    let(:contact) { create(:contact_with_name_email, school: school, user: user) }
    it 'uses locale from contact' do
      ClimateControl.modify FEATURE_FLAG_EMAILS_WITH_PREFERRED_LOCALE: 'true' do
        ClimateControl.modify SEND_AUTOMATED_EMAILS: 'true' do
          AlertMailer.with_contact_locale(contact: contact, events: []) { |mailer| mailer.alert_email.deliver_now }
        end
      end
      email = ActionMailer::Base.deliveries.last
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :cy)
    end
  end
end

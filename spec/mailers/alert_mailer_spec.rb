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
    context 'to single user' do
      it 'sends an email with mailgun tag in header' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
        expect(ActionMailer::Base.deliveries.count).to be 1
        expect(email.mailgun_headers['X-Mailgun-Tag']).to eql 'alerts'
      end

      it 'specifies a subject' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
        expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject')
      end

      it 'send to right to address' do
        AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
        expect(email.to).to contain_exactly(email_address)
      end

      context 'when locale is specified' do
        [:en, :cy].each do |locale|
          it "uses #{locale}" do
            AlertMailer.with(email_address: email_address, school: school, events: [], locale: locale).alert_email.deliver_now
            expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: locale)
          end
        end
      end

      context 'SEND_AUTOMATED_EMAILS env var is false' do
        let(:send_automated_emails) { 'false' }

        it 'does not send an email' do
          AlertMailer.with(email_address: email_address, school: school, events: []).alert_email.deliver_now
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end
    end

    context 'to multiple users' do
      let(:users) { create_list(:contact_with_name_email_phone, 2) }

      it 'sends an email with mailgun tag in header' do
        AlertMailer.with(users: users, school: school, events: []).alert_email.deliver_now
        expect(ActionMailer::Base.deliveries.count).to be 1
        expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: :en)
        expect(email.mailgun_headers['X-Mailgun-Tag']).to eql 'alerts'
      end

      it 'specifies a subject' do
        AlertMailer.with(users: users, school: school, events: []).alert_email.deliver_now
        expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject')
      end

      it 'send to right addresses' do
        AlertMailer.with(users: users, school: school, events: []).alert_email.deliver_now
        expect(email.to).to match_array(users.map(&:email_address))
      end

      context 'when locale is specified' do
        [:en, :cy].each do |locale|
          it "uses #{locale}" do
            AlertMailer.with(users: users, school: school, events: [], locale: locale).alert_email.deliver_now
            expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject', locale: locale)
          end
        end
      end

      context 'SEND_AUTOMATED_EMAILS env var is false' do
        let(:send_automated_emails) { 'false' }

        it 'does not send an email' do
          AlertMailer.with(users: users, school: school, events: []).alert_email.deliver_now
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
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

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AlertMailer do
  include EmailHelpers

  let(:school)                { create(:school) }
  let(:email)                 { last_email }
  let(:send_automated_emails) { 'true' }

  before { stub_const('ENV', ENV.to_h.merge('SEND_AUTOMATED_EMAILS' => send_automated_emails)) }

  describe '#alert_email' do
    shared_examples 'an alert email' do
      let(:locale) { nil }

      it 'sends an email with mailgun tag in header' do
        expect(ActionMailer::Base.deliveries.count).to be 1
        expect(email.mailgun_headers['X-Mailgun-Tag']).to eq('alerts')
      end

      it 'sends an email with a mailgun deliverytime option' do
        expect(DateTime.rfc2822(email.mailgun_options[:deliverytime]).in_time_zone).to \
          be_within(1.minute).of(15.minutes.from_now)
      end

      it 'specifies a subject' do
        expect(email.subject).to eq("#{school.name} weekly alerts")
      end

      it 'send to right to address' do
        expect(email.to).to match_array(email_address)
      end

      it 'uses the correct body font-size' do
        expect(html_email(email).at('p')['style'].split(/; */)).to include('font-size: 18px')
      end

      %i[en cy].each do |locale|
        context "with #{locale}" do
          let(:locale) { locale }

          it "uses #{locale}" do
            expect(email.subject).to \
              eq(I18n.t('alert_mailer.alert_email.subject_2024', school_name: school.name, locale:))
          end
        end
      end

      context 'when SEND_AUTOMATED_EMAILS env var is false' do
        let(:send_automated_emails) { 'false' }

        before { described_class.with(email_address:, school:, events: []).alert_email.deliver_now }

        it 'does not send an email' do
          expect(ActionMailer::Base.deliveries.count).to be 0
        end
      end
    end

    context 'when to a single user' do
      let(:email_address) { 'blah@blah.com' }

      before { described_class.with(email_address:, school:, events: [], locale:).alert_email.deliver_now }

      it_behaves_like 'an alert email'
    end

    context 'when to multiple users' do
      let(:users) { create_list(:contact_with_name_email_phone, 2) }
      let(:email_address) { users.map(&:email_address) }

      before { described_class.with(users:, school:, events: [], locale:).alert_email.deliver_now }

      it_behaves_like 'an alert email'
    end
  end

  describe '#with_contact_locale' do
    let(:user) { create(:user, preferred_locale: :cy) }
    let(:contact) { create(:contact_with_name_email, school: school, user: user) }

    it 'uses locale from contact' do
      described_class.with_contact_locale(contact: contact, events: []) { |mailer| mailer.alert_email.deliver_now }
      expect(email.subject).to eql I18n.t('alert_mailer.alert_email.subject_2024', school_name: school.name,
                                                                                   locale: :cy)
    end
  end
end

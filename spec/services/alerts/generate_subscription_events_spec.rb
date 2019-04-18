require 'rails_helper'

describe Alerts::GenerateSubscriptionEvents do

  let(:school)  { create(:school) }
  let(:rating){ 5.0 }
  let!(:alert)  { create(:alert, school: school, rating: rating) }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school, alert) }

  context 'no alerts' do
    it 'does nothing, no events created' do
      service.perform
      expect(AlertSubscriptionEvent.count).to be 0
    end
  end

  context 'alerts, but no subscriptions' do
    it 'does nothing, no events created' do
      create(:alert, school: school)
      service.perform
      expect(AlertSubscriptionEvent.count).to be 0
    end
  end

  context 'alerts and subscriptions' do
    let(:sms_active){ true }
    let(:email_active){ true }
    let!(:alert_type_rating){ create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, sms_active: sms_active, email_active: email_active}

    let!(:email_contact)            { create(:contact_with_name_email, school: school) }
    let!(:sms_contact)              { create(:contact_with_name_phone, school: school) }
    let!(:sms_and_email_contact)    { create(:contact_with_name_email_phone, school: school) }

    context 'contacts with email, sms and both' do

      context 'with some content' do

        let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

        it 'creates events and associates the content versions' do
          expect { service.perform }.to change { AlertSubscriptionEvent.count }.by(4)

          expect(email_contact.alert_subscription_events.count).to be 1
          expect(email_contact.alert_subscription_events.first.communication_type).to eq 'email'
          expect(email_contact.alert_subscription_events.first.content_version).to eq content_version
          expect(sms_contact.alert_subscription_events.count).to be 1
          expect(sms_contact.alert_subscription_events.first.communication_type).to eq 'sms'
          expect(sms_contact.alert_subscription_events.first.content_version).to eq content_version
          expect(sms_and_email_contact.alert_subscription_events.count).to be 2
          expect(sms_and_email_contact.alert_subscription_events.pluck(:communication_type)).to match_array ['sms','email']
        end

        it 'ignores if events already exist' do
          AlertSubscriptionEvent.create(alert: alert, contact: email_contact, status: :sent, communication_type: :email)
          expect(AlertSubscriptionEvent.count).to be 1
          service.perform
          expect(AlertSubscriptionEvent.count).to be 4
          expect(AlertSubscriptionEvent.first.status).to eq 'sent'
        end

        context 'where SMS content is inactive' do
          let(:sms_active){ false }
          it 'does not create events for that type' do
            service.perform
            expect(email_contact.alert_subscription_events.count).to eq 1
            expect(sms_contact.alert_subscription_events.count).to eq 0
            expect(sms_and_email_contact.alert_subscription_events.count).to eq 1
          end
        end

        context 'where email content is inactive' do
          let(:email_active){ false }
          it 'does not create events for that type' do
            service.perform
            expect(email_contact.alert_subscription_events.count).to eq 0
            expect(sms_contact.alert_subscription_events.count).to eq 1
            expect(sms_and_email_contact.alert_subscription_events.count).to eq 1
          end
        end

      end

    end
  end
end

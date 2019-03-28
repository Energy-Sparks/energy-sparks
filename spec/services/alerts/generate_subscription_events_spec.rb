require 'rails_helper'

describe Alerts::GenerateSubscriptionEvents do

  let(:school)  { create(:school) }
  let!(:alert)  { create(:alert, school: school) }
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
    let!(:email_contact)            { create(:contact_with_name_email, school: school) }
    let!(:sms_contact)              { create(:contact_with_name_phone, school: school) }
    let!(:sms_and_email_contact)    { create(:contact_with_name_email_phone, school: school) }

    let!(:alert_subscription_email)           { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [email_contact]) }
    let!(:alert_subscription_sms)             { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [sms_contact]) }
    let!(:alert_subscription_email_and_sms)   { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [sms_and_email_contact]) }

    context 'contacts with email, sms and both' do
      it 'creates events' do
        expect { service.perform }.to change { AlertSubscriptionEvent.count }.by(4)

        expect(email_contact.alert_subscription_events.count).to be 1
        expect(email_contact.alert_subscription_events.first.communication_type).to eq 'email'
        expect(sms_contact.alert_subscription_events.count).to be 1
        expect(sms_contact.alert_subscription_events.first.communication_type).to eq 'sms'
        expect(sms_and_email_contact.alert_subscription_events.count).to be 2
        expect(sms_and_email_contact.alert_subscription_events.pluck(:communication_type)).to match_array ['sms','email']
      end

      it 'ignores if events already exist' do
        AlertSubscriptionEvent.create(alert: alert, alert_subscription: alert_subscription_email, contact: email_contact, status: :sent, communication_type: :email)
        expect(AlertSubscriptionEvent.count).to be 1
        service.perform
        expect(AlertSubscriptionEvent.count).to be 4
        expect(AlertSubscriptionEvent.first.status).to eq 'sent'
      end
    end
  end
end

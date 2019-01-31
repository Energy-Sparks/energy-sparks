require 'rails_helper'

describe Alerts::GenerateSubscriptionEvents do

  let(:school)  { create(:school) }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school) }

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
    let!(:alert)               { create(:alert, school: school) }
    let!(:contact)             { create(:contact_with_name_email, school: school) }
    let!(:alert_subscription)  { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [contact]) }

    it 'creates events' do
      expect { service.perform }.to change { AlertSubscriptionEvent.count }.by(1)
    end

    it 'ignores if events already exist' do
      AlertSubscriptionEvent.create(alert: alert, alert_subscription: alert_subscription, contact: contact, status: :sent)
      service.perform
      expect(AlertSubscriptionEvent.count).to be 1
      expect(AlertSubscriptionEvent.first.status).to eq 'sent'
    end
  end
end
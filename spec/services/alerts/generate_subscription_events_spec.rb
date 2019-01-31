require 'rails_helper'

describe Alerts::GenerateSubscriptionEvents do

  let(:service)             { Alerts::GenerateSubscriptionEvents.new }

  context 'no alerts' do
    it 'does nothing, no events created' do
      service.perform
      expect(AlertSubscriptionEvent.count).to be 0
    end
  end

  context 'alerts, but no subscriptions' do
    it 'does nothing, no events created' do
      create(:alert)
      service.perform
      expect(AlertSubscriptionEvent.count).to be 0
    end
  end

  context 'alerts and subscriptions' do

    let(:alert)               { create(:alert) }
    let(:alert_subscription)  { create(:alert_subscription_with_contacts, alert_type: alert.alert_type) }

    pending 'creates events' do
      expect { service.perform }.to change { AlertSubscriptionEvent.count }.by(1)
    end

    it 'ignores if events already exist' do
      AlertSubscriptionEvent.create(alert: alert, alert_subscription: alert_subscription)
      service.perform
      expect(AlertSubscriptionEvent.count).to be 1
    end
  end

end
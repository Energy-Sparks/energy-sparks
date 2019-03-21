require 'rails_helper'

describe Alerts::GenerateEmailNotifications do
  let(:school)                      { create(:school) }
  let!(:alert_1)                    { create(:alert, school: school) }
  let!(:alert_2)                    { create(:alert, school: school) }
  let!(:email_contact)              { create(:contact_with_name_email, school: school) }
  let!(:alert_subscription_email_1) { create(:alert_subscription, alert_type: alert_1.alert_type, school: school, contacts: [email_contact]) }
  let!(:alert_subscription_email_2) { create(:alert_subscription, alert_type: alert_2.alert_type, school: school, contacts: [email_contact]) }

  it 'sends email, only once' do
    alert_subscription_event_1 = AlertSubscriptionEvent.create(alert: alert_1, alert_subscription: alert_subscription_email_1, communication_type: :email, contact: email_contact, status: :pending)
    alert_subscription_event_2 = AlertSubscriptionEvent.create(alert: alert_2, alert_subscription: alert_subscription_email_2, communication_type: :email, contact: email_contact, status: :pending)

    Alerts::GenerateEmailNotifications.new.perform

    alert_subscription_event_1.reload
    alert_subscription_event_2.reload

    expect(alert_subscription_event_1.status).to eq 'sent'
    expect(alert_subscription_event_2.status).to eq 'sent'

    expect(alert_subscription_event_1.message_id).to_not be_empty
    expect(alert_subscription_event_1.message_id).to eq alert_subscription_event_2.message_id

    expect(ActionMailer::Base.deliveries.count).to be 1
    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to include('Energy Sparks alerts')
    expect(email.html_part.body.to_s).to include('ImportantContent')

    ActionMailer::Base.deliveries.clear

    Alerts::GenerateEmailNotifications.new.perform
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end

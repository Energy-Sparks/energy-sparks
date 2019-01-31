require 'rails_helper'

describe Alerts::GenerateEmailNotifications do
  let(:school)                    { create(:school) }
  let!(:alert)                    { create(:alert, school: school) }
  let!(:email_contact)            { create(:contact_with_name_email, school: school) }
  let!(:alert_subscription_email) { create(:alert_subscription, alert_type: alert.alert_type, school: school, contacts: [email_contact]) }

  it 'sends email, only once' do
    alert_subscription_event = AlertSubscriptionEvent.create(alert: alert, alert_subscription: alert_subscription_email, communication_type: :email, contact: email_contact, status: :pending)
    Alerts::GenerateEmailNotifications.new.perform
    expect(AlertSubscriptionEvent.find(alert_subscription_event.id).status).to eq 'sent'
    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to include('Energy Sparks alerts')
    expect(email.html_part.body.to_s).to include('ImportantContent')

    ActionMailer::Base.deliveries.clear
    Alerts::GenerateEmailNotifications.new.perform
    expect(ActionMailer::Base.deliveries).to be_empty
  end
end

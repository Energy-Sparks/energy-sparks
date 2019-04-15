require 'rails_helper'

describe Alerts::GenerateEmailNotifications do
  let(:school)                      { create(:school) }
  let!(:alert_1)                    { create(:alert, school: school) }
  let!(:alert_2)                    { create(:alert, school: school) }
  let!(:email_contact)              { create(:contact_with_name_email, school: school) }
  let!(:alert_subscription_email_1) { create(:alert_subscription, alert_type: alert_1.alert_type, school: school, contacts: [email_contact]) }
  let!(:alert_subscription_email_2) { create(:alert_subscription, alert_type: alert_2.alert_type, school: school, contacts: [email_contact]) }

  let!(:alert_type_rating_1){ create :alert_type_rating, alert_type: alert_1.alert_type, email_active: true }
  let!(:alert_type_rating_2){ create :alert_type_rating, alert_type: alert_2.alert_type, email_active: true }
  let!(:content_version_1){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_1, email_title: 'You need to do something!', email_content: 'You really do'}
  let!(:content_version_2){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_2, email_title: 'You need to fix something!', email_content: 'You really do'}

  it 'sends email, only once' do
    alert_subscription_event_1 = AlertSubscriptionEvent.create(alert: alert_1, alert_subscription: alert_subscription_email_1, communication_type: :email, contact: email_contact, status: :pending, content_version: content_version_1)
    alert_subscription_event_2 = AlertSubscriptionEvent.create(alert: alert_2, alert_subscription: alert_subscription_email_2, communication_type: :email, contact: email_contact, status: :pending, content_version: content_version_2)

    Alerts::GenerateEmailNotifications.new.perform

    alert_subscription_event_1.reload
    alert_subscription_event_2.reload

    expect(alert_subscription_event_1.status).to eq 'sent'
    expect(alert_subscription_event_2.status).to eq 'sent'

    expect(alert_subscription_event_1.email_id).to_not be_nil
    expect(alert_subscription_event_1.email_id).to eq alert_subscription_event_2.email_id
    expect(Email.find(alert_subscription_event_1.email_id).sent?).to be true

    expect(ActionMailer::Base.deliveries.count).to be 1
    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to include('Energy Sparks alerts')
    expect(email.html_part.body.to_s).to include('You need to do something')
    expect(email.html_part.body.to_s).to include('You need to fix something')

    ActionMailer::Base.deliveries.clear

    Alerts::GenerateEmailNotifications.new.perform
    expect(ActionMailer::Base.deliveries).to be_empty
    expect(Email.count).to be 1
  end
end

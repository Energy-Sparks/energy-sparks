require 'rails_helper'

describe Alerts::GenerateSmsNotifications do
  let(:school)                      { create(:school) }
  let!(:alert_1)                    { create(:alert, school: school) }
  let!(:alert_2)                    { create(:alert, school: school) }
  let!(:sms_contact)              { create(:contact_with_name_phone, school: school) }
  let!(:alert_subscription_sms_1) { create(:alert_subscription, alert_type: alert_1.alert_type, school: school, contacts: [sms_contact]) }
  let!(:alert_subscription_sms_2) { create(:alert_subscription, alert_type: alert_2.alert_type, school: school, contacts: [sms_contact]) }

  let!(:alert_type_rating_1){ create :alert_type_rating, alert_type: alert_1.alert_type, sms_active: true }
  let!(:alert_type_rating_2){ create :alert_type_rating, alert_type: alert_2.alert_type, sms_active: true }
  let!(:content_version_1){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_1, sms_content: 'You need to do something!'}
  let!(:content_version_2){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_2, sms_content: 'You need to fix something!'}

  it 'sends sms, one, per alert' do
    send_sms_service = instance_double('send_sms_service')

    expect(SendSms).to receive(:new).with("EnergySparks alert: You need to do something!", sms_contact.mobile_phone_number).and_return(send_sms_service).ordered
    expect(send_sms_service).to receive(:send).ordered
    expect(SendSms).to receive(:new).with("EnergySparks alert: You need to fix something!", sms_contact.mobile_phone_number).and_return(send_sms_service).ordered
    expect(send_sms_service).to receive(:send).ordered

    alert_subscription_event_1 = AlertSubscriptionEvent.create(alert: alert_1, alert_subscription: alert_subscription_sms_1, communication_type: :sms, contact: sms_contact, status: :pending, content_version: content_version_1)
    alert_subscription_event_2 = AlertSubscriptionEvent.create(alert: alert_2, alert_subscription: alert_subscription_sms_2, communication_type: :sms, contact: sms_contact, status: :pending, content_version: content_version_2)

    Alerts::GenerateSmsNotifications.new.perform

    expect(AlertSubscriptionEvent.find(alert_subscription_event_1.id).status).to eq 'sent'
    expect(AlertSubscriptionEvent.find(alert_subscription_event_2.id).status).to eq 'sent'

    Alerts::GenerateSmsNotifications.new.perform
  end
end

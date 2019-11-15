require 'rails_helper'

describe Alerts::GenerateSmsNotifications do
  let(:school)               { create(:school) }
  let(:alert_generation_run) { create(:alert_generation_run, school: school) }
  let(:alert_1)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let(:alert_2)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let!(:sms_contact)         { create(:contact_with_name_phone, school: school) }

  let!(:alert_type_rating_1){ create :alert_type_rating, alert_type: alert_1.alert_type, sms_active: true }
  let!(:alert_type_rating_2){ create :alert_type_rating, alert_type: alert_2.alert_type, sms_active: true }
  let!(:content_version_1){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_1, sms_content: 'You need to do something!'}
  let!(:content_version_2){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_2, sms_content: 'You need to fix something!'}

  let!(:subscription_generation_run){ create(:subscription_generation_run, school: school) }

  it 'sends sms, one, per alert' do
    send_sms_class = double('send_sms_service')
    send_sms_service = instance_double('send_sms_service')

    expect(send_sms_class).to receive(:new).with("EnergySparks alert: You need to do something!", sms_contact.mobile_phone_number).and_return(send_sms_service).ordered
    expect(send_sms_service).to receive(:send).ordered
    expect(send_sms_class).to receive(:new).with("EnergySparks alert: You need to fix something!", sms_contact.mobile_phone_number).and_return(send_sms_service).ordered
    expect(send_sms_service).to receive(:send).ordered

    Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])
    Alerts::GenerateSmsNotifications.new(subscription_generation_run: subscription_generation_run, send_sms_service: send_sms_class).perform

    expect(AlertSubscriptionEvent.all.all?{|event| event.status == 'sent'}).to eq(true)

    Alerts::GenerateSmsNotifications.new(subscription_generation_run: subscription_generation_run, send_sms_service: send_sms_class).perform
  end
end

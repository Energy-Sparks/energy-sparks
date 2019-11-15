require 'rails_helper'

describe Alerts::GenerateEmailNotifications do
  let(:school)               { create(:school) }
  let(:alert_generation_run) { create(:alert_generation_run, school: school) }
  let(:alert_1)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let(:alert_2)              { create(:alert, school: school, alert_generation_run: alert_generation_run) }
  let!(:email_contact)       { create(:contact_with_name_email, school: school) }

  let(:alert_type_rating_1){ create :alert_type_rating, alert_type: alert_1.alert_type, email_active: true }
  let(:alert_type_rating_2){ create :alert_type_rating, alert_type: alert_2.alert_type, email_active: true }
  let!(:content_version_1){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_1, email_title: 'You need to do something!', email_content: 'You really do'}
  let!(:content_version_2){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating_2, email_title: 'You need to fix something!', email_content: 'You really do'}

  let!(:subscription_generation_run){ create(:subscription_generation_run, school: school) }

  it 'sends email, only once and offers a way to unsubscribe' do
    Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])

    alert_subscription_event_1 = AlertSubscriptionEvent.find_by!(content_version: content_version_1)
    alert_subscription_event_2 = AlertSubscriptionEvent.find_by!(content_version: content_version_2)

    Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform

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

    expect(email.html_part.body.to_s).to include("I don't want to see alerts like this")
    expect(email.html_part.body.to_s).to include(alert_subscription_event_1.unsubscription_uuid)

    expect(email.html_part.body.to_s).to_not include('Find Out More')

    ActionMailer::Base.deliveries.clear

    Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
    expect(ActionMailer::Base.deliveries).to be_empty
    expect(Email.count).to be 1
  end

  it 'links to a find out more if there is one associated with the content' do
    alert_type_rating_1.update!(find_out_more_active: true)

    Alerts::GenerateContent.new(school).perform
    Alerts::GenerateSubscriptionEvents.new(school, subscription_generation_run: subscription_generation_run).perform([alert_1, alert_2])

    Alerts::GenerateEmailNotifications.new(subscription_generation_run: subscription_generation_run).perform
    email = ActionMailer::Base.deliveries.last

    expect(email.subject).to include('Energy Sparks alerts')
    expect(email.html_part.body.to_s).to include('You need to do something')
    expect(email.html_part.body.to_s).to include('Find Out More')

  end
end

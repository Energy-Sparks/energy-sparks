require 'rails_helper'

describe Alerts::GenerateSubscriptionEvents do

  let(:school)  { create(:school) }
  let(:rating){ 5.0 }
  let(:alert_type){ create(:alert_type, frequency: :weekly) }
  let!(:alert)  { create(:alert, school: school, rating: rating, alert_type: alert_type) }
  let(:service) { Alerts::GenerateSubscriptionEvents.new(school) }

  context 'no alerts' do
    it 'does nothing, no events created' do
      service.perform(frequency: [:weekly])
      expect(AlertSubscriptionEvent.count).to eq 0
    end
  end

  context 'alerts, but no subscriptions' do
    it 'does nothing, no events created' do
      create(:alert, school: school)
      service.perform(frequency: [:weekly])
      expect(AlertSubscriptionEvent.count).to eq 0
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

        it 'does not process anything the frequency is set to empty' do
          expect { service.perform(frequency: [])}.to_not change { AlertSubscriptionEvent.count }
        end

        it 'does not process anything the frequency is set to a different frequency' do
          expect { service.perform(frequency: [:termly])}.to_not change { AlertSubscriptionEvent.count }
        end

        it 'uses an existing run if one is passed inn' do
          content_generation_run = create(:content_generation_run, school: school)
          service.perform(frequency: [:weekly], content_generation_run: content_generation_run)
          expect(ContentGenerationRun.count).to be 1
          expect(content_generation_run.alert_subscription_events.size).to eq(4)
        end

        it 'creates a content generation run if one is not passed in' do
          service.perform(frequency: [:weekly])
          expect(ContentGenerationRun.count).to be 1
          content_generation_run = ContentGenerationRun.first
          expect(content_generation_run.alert_subscription_events.size).to eq(4)
          expect(content_generation_run.school).to eq(school)
        end

        it 'assigns a find out more from the run, if it matches the content version' do
          content_generation_run = create(:content_generation_run, school: school)
          find_out_more = create(:find_out_more, content_version: content_version, alert: alert, content_generation_run: content_generation_run)

          service.perform(frequency: [:weekly], content_generation_run: content_generation_run)
          alert_subscription_event = content_generation_run.alert_subscription_events.first
          expect(alert_subscription_event.find_out_more).to eq(find_out_more)
        end

        it 'does not assign the find out more if it is from different content' do
          content_version_2 = create :alert_type_rating_content_version, alert_type_rating: alert_type_rating
          content_generation_run = create(:content_generation_run, school: school)
          find_out_more = create(:find_out_more, content_version: content_version_2, alert: alert, content_generation_run: content_generation_run)

          service.perform(frequency: [:weekly], content_generation_run: content_generation_run)
          alert_subscription_event = content_generation_run.alert_subscription_events.first
          expect(alert_subscription_event.find_out_more).to be_nil
        end

        it 'creates events and associates the content versions' do
          expect { service.perform(frequency: [:weekly])}.to change { AlertSubscriptionEvent.count }.by(4)

          expect(email_contact.alert_subscription_events.count).to eq 1
          expect(email_contact.alert_subscription_events.first.communication_type).to eq 'email'
          expect(email_contact.alert_subscription_events.first.content_version).to eq content_version
          expect(sms_contact.alert_subscription_events.count).to eq 1
          expect(sms_contact.alert_subscription_events.first.communication_type).to eq 'sms'
          expect(sms_contact.alert_subscription_events.first.content_version).to eq content_version
          expect(sms_and_email_contact.alert_subscription_events.count).to eq 2
          expect(sms_and_email_contact.alert_subscription_events.pluck(:communication_type)).to match_array ['sms','email']
        end

        it 'ignores if events already exist' do
          AlertSubscriptionEvent.create(alert: alert, contact: email_contact, status: :sent, communication_type: :email, content_generation_run: ContentGenerationRun.create(school: school))
          expect(AlertSubscriptionEvent.count).to eq 1
          service.perform(frequency: [:weekly])
          expect(AlertSubscriptionEvent.count).to eq 4
          expect(AlertSubscriptionEvent.first.status).to eq 'sent'
        end

        context 'where SMS content is inactive' do
          let(:sms_active){ false }
          it 'does not create events for that type' do
            service.perform(frequency: [:weekly])
            expect(email_contact.alert_subscription_events.count).to eq 1
            expect(sms_contact.alert_subscription_events.count).to eq 0
            expect(sms_and_email_contact.alert_subscription_events.count).to eq 1
          end
        end

        context 'where email content is inactive' do
          let(:email_active){ false }
          it 'does not create events for that type' do
            service.perform(frequency: [:weekly])
            expect(email_contact.alert_subscription_events.count).to eq 0
            expect(sms_contact.alert_subscription_events.count).to eq 1
            expect(sms_and_email_contact.alert_subscription_events.count).to eq 1
          end
        end

      end

    end
  end
end

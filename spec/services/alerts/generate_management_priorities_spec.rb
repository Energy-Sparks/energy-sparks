require 'rails_helper'

describe Alerts::GenerateManagementPriorities do

  let(:school)                  { create(:school) }
  let(:content_generation_run)  { create(:content_generation_run, school: school) }
  let(:service)                 { Alerts::GenerateManagementPriorities.new(content_generation_run: content_generation_run) }
  let(:latest)                  { school.latest_alerts_without_exception }

  context 'no alerts' do
    it 'does nothing, no alerts created' do
      service.perform(school.alerts.latest)
      expect(ManagementPriority.count).to be 0
    end
  end

  context 'alerts, but no management priorities configured' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform(school.alerts.latest)
      expect(ManagementPriority.count).to be 0
    end
  end

  context 'when there are find out mores that match the alert type' do
    let(:rating){ 5.0 }
    let!(:alert){ create(:alert, school: school, rating: rating)}
    let!(:alert_type_rating) do
      create :alert_type_rating,
        alert_type: alert.alert_type,
        rating_from: 1,
        rating_to: 6,
        management_priorities_active: management_priorities_active
    end
    let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    let(:management_priorities_active){ true }

    context 'where the rating matches the range' do

      it 'creates a management priority  pairing the alert and the content for each active dashboard' do
        service.perform(latest)
        expect(content_generation_run.management_priorities.count).to be 1

        priority = content_generation_run.management_priorities.first
        expect(priority.alert).to eq(alert)
        expect(priority.content_version).to eq(content_version)
        expect(priority.priority).to eq(0.15)
      end

      it 'assigns a find out more from the run, if it matches the content version' do
        find_out_more = create(:find_out_more, content_version: content_version, alert: alert, content_generation_run: content_generation_run)
        service.perform(latest)
        priority  = content_generation_run.management_priorities.first
        expect(priority.find_out_more).to eq(find_out_more)
      end

      it 'does not assign the find out more if it is from different content' do
        content_version_2 = create :alert_type_rating_content_version, alert_type_rating: alert_type_rating
        find_out_more = create(:find_out_more, content_version: content_version_2, alert: alert, content_generation_run: content_generation_run)

        service.perform(latest)
        priority = content_generation_run.management_priorities.first
        expect(priority.find_out_more).to eq(nil)
      end

      it 'does not create any priorities if there is an alert type exception' do
        SchoolAlertTypeException.create(school: school, alert_type: alert.alert_type)
        expect { service.perform(latest)}.to change { content_generation_run.alert_subscription_events.count }.by(0)
      end

      context 'where the management priorities are not active' do
        let(:management_priorities_active){ false }
        it 'does not include the alert' do
          service.perform(school.alerts.latest)
          expect(content_generation_run.management_priorities.count).to be 0
        end
      end
    end
  end
end

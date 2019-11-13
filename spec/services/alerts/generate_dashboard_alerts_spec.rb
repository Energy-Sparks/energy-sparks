require 'rails_helper'

describe Alerts::GenerateDashboardAlerts do

  let(:school)  { create(:school) }
  let(:content_generation_run){ create(:content_generation_run, school: school) }
  let(:service) { Alerts::GenerateDashboardAlerts.new(content_generation_run: content_generation_run) }

  context 'no alerts' do
    it 'does nothing, no dashboard alerts created' do
      service.perform(school.latest_alerts_without_exclusions)
      expect(DashboardAlert.count).to be 0
    end
  end

  context 'alerts, but no dashboard alerts configured' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform(school.latest_alerts_without_exclusions)
      expect(DashboardAlert.count).to be 0
    end
  end

  context 'when there are find out mores that match the alert type' do
    let(:rating){ 5.0 }
    let(:teacher_active){ true }
    let(:pupil_active){ true }
    let(:public_active){ true }
    let(:management_active){ true }
    let(:alert_generation_run) { create(:alert_generation_run, school: school) }
    let!(:alert)               { create(:alert, school: school, rating: rating, alert_generation_run: alert_generation_run)}
    let!(:alert_type_rating) do
      create :alert_type_rating,
        alert_type: alert.alert_type,
        rating_from: 1,
        rating_to: 6,
        teacher_dashboard_alert_active: teacher_active,
        pupil_dashboard_alert_active: pupil_active,
        public_dashboard_alert_active: public_active,
        management_dashboard_alert_active: management_active
    end
    let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    context 'where the rating matches the range' do

      it 'creates a dashboard alert pairing the alert and the content for each active dashboard' do
        service.perform(school.latest_alerts_without_exclusions)
        expect(content_generation_run.dashboard_alerts.count).to be 4

        teacher_alert = content_generation_run.dashboard_alerts.teacher_dashboard.first
        expect(teacher_alert.alert).to eq(alert)
        expect(teacher_alert.content_version).to eq(content_version)
        expect(teacher_alert.priority).to eq(0.15)

        pupil_alert = content_generation_run.dashboard_alerts.pupil_dashboard.first
        expect(pupil_alert.alert).to eq(alert)
        expect(pupil_alert.content_version).to eq(content_version)

        public_alert = content_generation_run.dashboard_alerts.public_dashboard.first
        expect(public_alert.alert).to eq(alert)
        expect(public_alert.content_version).to eq(content_version)

        management_alert = content_generation_run.dashboard_alerts.management_dashboard.first
        expect(management_alert.alert).to eq(alert)
        expect(management_alert.content_version).to eq(content_version)
      end

      it 'assigns a find out more from the run, if it matches the content version' do
        find_out_more = create(:find_out_more, content_version: content_version, alert: alert, content_generation_run: content_generation_run)
        service.perform(school.latest_alerts_without_exclusions)
        dashboard_alert = content_generation_run.dashboard_alerts.first
        expect(dashboard_alert.find_out_more).to eq(find_out_more)
      end

      it 'does not assign the find out more if it is from different content' do
        content_version_2 = create :alert_type_rating_content_version, alert_type_rating: alert_type_rating
        find_out_more = create(:find_out_more, content_version: content_version_2, alert: alert, content_generation_run: content_generation_run)

        service.perform(school.latest_alerts_without_exclusions)
        dashboard_alert = content_generation_run.dashboard_alerts.first
        expect(dashboard_alert.find_out_more).to eq(nil)
      end

      context 'where the pupil alerts are not active' do
        let(:pupil_active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.dashboard_alerts.pupil_dashboard.count).to be 0
        end
      end

      context 'where the teacher alerts are not active' do
        let(:teacher_active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.dashboard_alerts.teacher_dashboard.count).to be 0
        end
      end

      context 'where the public alerts are not active' do
        let(:public_active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.dashboard_alerts.public_dashboard.count).to be 0
        end
      end

      context 'where the management alerts are not active' do
        let(:management_active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.dashboard_alerts.management_dashboard.count).to be 0
        end
      end

      context 'when there is an exception' do
        it 'does not create any of the dashboard alerts' do
          SchoolAlertTypeExclusion.create(school: school, alert_type: alert.alert_type)
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.dashboard_alerts.management_dashboard.count).to be 0
          expect(content_generation_run.dashboard_alerts.public_dashboard.count).to be 0
          expect(content_generation_run.dashboard_alerts.teacher_dashboard.count).to be 0
          expect(content_generation_run.dashboard_alerts.pupil_dashboard.count).to be 0
        end
      end
    end
  end
end

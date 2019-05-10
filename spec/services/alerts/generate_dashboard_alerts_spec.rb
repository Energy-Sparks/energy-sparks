require 'rails_helper'

describe Alerts::GenerateDashboardAlerts do

  let(:school)  { create(:school) }
  let(:service) { Alerts::GenerateDashboardAlerts.new(school) }

  context 'no alerts' do
    it 'does nothing, no dashboard alerts created' do
      service.perform
      expect(DashboardAlert.count).to be 0
    end
  end

  context 'alerts, but no dashboard alerts configured' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform
      expect(DashboardAlert.count).to be 0
    end
  end

  context 'when there are find out mores that match the alert type' do
    let(:rating){ 5.0 }
    let(:teacher_active){ true }
    let(:pupil_active){ true }
    let!(:alert){ create(:alert, school: school, rating: rating)}
    let!(:alert_type_rating){ create :alert_type_rating, alert_type: alert.alert_type, rating_from: 1, rating_to: 6, teacher_dashboard_alert_active: teacher_active, pupil_dashboard_alert_active: pupil_active}
    let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    context 'where the rating matches the range' do

      it 'uses an existing run if one is passed in' do
        content_generation_run = create(:content_generation_run, school: school)
        service.perform(content_generation_run: content_generation_run)
        expect(ContentGenerationRun.count).to be 1
        expect(content_generation_run.dashboard_alerts.size).to eq(2)
      end

      it 'creates a content generation run if one is not passed in' do
        service.perform
        expect(ContentGenerationRun.count).to be 1
        content_generation_run = ContentGenerationRun.first
        expect(content_generation_run.dashboard_alerts.size).to eq(2)
        expect(content_generation_run.school).to eq(school)
      end

      it 'creates a find out more pairing the alert and the content for each active dashboard' do
        service.perform
        expect(DashboardAlert.count).to be 2
        teacher_alert = DashboardAlert.teacher.first
        expect(teacher_alert.alert).to eq(alert)
        expect(teacher_alert.content_version).to eq(content_version)
        pupil_alert = DashboardAlert.pupil.first
        expect(pupil_alert.alert).to eq(alert)
        expect(pupil_alert.content_version).to eq(content_version)
      end

      it 'assigns a find out more from the run, if it matches the content version' do
        content_generation_run = create(:content_generation_run, school: school)
        find_out_more = create(:find_out_more, content_version: content_version, alert: alert, content_generation_run: content_generation_run)

        service.perform(content_generation_run: content_generation_run)
        dashboard_alert = content_generation_run.dashboard_alerts.first
        expect(dashboard_alert.find_out_more).to eq(find_out_more)
      end

      it 'does not assign the find out more if it is from different content' do
        content_version_2 = create :alert_type_rating_content_version, alert_type_rating: alert_type_rating
        content_generation_run = create(:content_generation_run, school: school)
        find_out_more = create(:find_out_more, content_version: content_version_2, alert: alert, content_generation_run: content_generation_run)

        service.perform(content_generation_run: content_generation_run)
        dashboard_alert = content_generation_run.dashboard_alerts.first
        expect(dashboard_alert.find_out_more).to eq(nil)
      end

      context 'where the pupil alerts are not active' do
        let(:pupil_active){ false }
        it 'does not include the alert' do
          service.perform
          expect(DashboardAlert.pupil.count).to be 0
          expect(DashboardAlert.teacher.count).to be 1
        end
      end

      context 'where the teacher alerts are not active' do
        let(:teacher_active){ false }
        it 'does not include the alert' do
          service.perform
          expect(DashboardAlert.pupil.count).to be 1
          expect(DashboardAlert.teacher.count).to be 0
        end
      end

    end
  end

end

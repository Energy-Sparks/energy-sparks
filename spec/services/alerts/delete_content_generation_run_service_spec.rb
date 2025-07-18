require 'rails_helper'

describe Alerts::DeleteContentGenerationRunService, type: :service do
  let(:created_at) { Time.zone.now }
  let!(:school)            { create(:school) }
  let!(:run)               { ContentGenerationRun.create(created_at: created_at) }

  let(:service)   { Alerts::DeleteContentGenerationRunService.new }

  it 'defaults to two weeks ago' do
    expect(service.older_than).to eql(14.days.ago.to_date)
  end

  it 'doesnt delete new runs' do
    date_time = (Time.zone.now - 14.days)
    school.content_generation_runs.create!(created_at: date_time + 1.day)
    school.content_generation_runs.create!(created_at: date_time + 1.week)
    school.content_generation_runs.create!(created_at: Time.zone.now)
    expect { service.delete! }.not_to change(ContentGenerationRun, :count)
  end

  context 'when there are older runs to delete' do
    let(:school) { create :school }
    let(:electricity_fuel_alert_type) { create(:alert_type, fuel_type: :electricity, frequency: :termly) }
    let(:alert_type_rating) { create(:alert_type_rating, alert_type: electricity_fuel_alert_type) }

    let(:content_version_1) { create(:alert_type_rating_content_version, alert_type_rating: alert_type_rating)}
    let(:alert_1) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:alert_2) { create(:alert, alert_type: electricity_fuel_alert_type) }
    let(:older_than_date) { Alerts::DeleteContentGenerationRunService::DEFAULT_OLDER_THAN }
    let(:content_generation_run_1) { create(:content_generation_run, school: school, created_at: older_than_date) }
    let(:content_generation_run_2) { create(:content_generation_run, school: school, created_at: older_than_date + 1.day) }

    let!(:dashboard_alert_1) { create(:dashboard_alert, alert: alert_1, content_version: content_version_1, content_generation_run: content_generation_run_1) }
    let!(:dashboard_alert_2) { create(:dashboard_alert, alert: alert_2, content_version: content_version_1, content_generation_run: content_generation_run_2) }
    let!(:management_priority_1) { create(:management_priority, alert: alert_1, content_generation_run: content_generation_run_1) }
    let!(:management_priority_2) { create(:management_priority, alert: alert_2, content_generation_run: content_generation_run_2) }
    let!(:management_dashboard_table_1) { create(:management_dashboard_table, alert: alert_1, content_generation_run: content_generation_run_1) }
    let!(:management_dashboard_table_2) { create(:management_dashboard_table, alert: alert_2, content_generation_run: content_generation_run_2) }
    let!(:find_out_more_1) { create(:find_out_more, alert: alert_1, content_generation_run: content_generation_run_1) }
    let!(:find_out_more_2) { create(:find_out_more, alert: alert_2, content_generation_run: content_generation_run_2) }

    it 'deletes only the older runs and all of the older runs dependent objects' do
      expect(ContentGenerationRun.count).to eq 2
      expect(DashboardAlert.count).to eq(2)
      expect(ManagementPriority.count).to eq(2)
      expect(ManagementDashboardTable.count).to eq(2)
      expect(FindOutMore.count).to eq(2)
      cv_ids = FindOutMore.all.pluck(:alert_type_rating_content_version_id)
      alert_type_rating_content_versions = AlertTypeRatingContentVersion.where(id: cv_ids)
      expect(alert_type_rating_content_versions.count).to eq(2)
      alert_type_ratings = AlertTypeRating.where(id: alert_type_rating_content_versions.map(&:alert_type_rating_id))
      expect(alert_type_ratings.count).to eq(2)
      alert_types = AlertType.where(id: alert_type_ratings.map(&:alert_type_id))
      expect(alert_types.count).to eq(2)

      expect { service.delete! }.to change(ContentGenerationRun, :count).from(2).to(1) &
                                    change(DashboardAlert, :count).from(2).to(1) &
                                    change(ManagementPriority, :count).from(2).to(1) &
                                    change(ManagementDashboardTable, :count).from(2).to(1) &
                                    change(FindOutMore, :count).from(2).to(1) &
                                    not_change(AlertTypeRatingContentVersion.where(id: cv_ids), :count) &
                                    not_change(AlertTypeRating.where(id: alert_type_rating_content_versions.map(&:alert_type_rating_id)), :count) &
                                    not_change(AlertType.where(id: alert_type_ratings.map(&:alert_type_id)), :count)

      expect(ContentGenerationRun.first.created_at).to be > Alerts::DeleteContentGenerationRunService::DEFAULT_OLDER_THAN
    end
  end
end

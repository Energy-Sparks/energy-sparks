require 'rails_helper'

describe Alerts::GenerateManagementDashboardTables do

  let(:school)                  { create(:school) }
  let(:content_generation_run)  { create(:content_generation_run, school: school) }
  let(:service)                 { Alerts::GenerateManagementDashboardTables.new(content_generation_run: content_generation_run) }

  context 'no alerts' do
    it 'does nothing, no alerts created' do
      service.perform(school.latest_alerts_without_exclusions)
      expect(ManagementDashboardTable.count).to be 0
    end
  end

  context 'alerts, but no management dashboard tables configured' do
    it 'does nothing' do
      create(:alert, school: school)
      service.perform(school.latest_alerts_without_exclusions)
      expect(ManagementDashboardTable.count).to be 0
    end
  end

  context 'when there are management tables configured that match the alert type' do
    let(:rating){ 5.0 }
    let!(:alert){ create(:alert, school: school, rating: rating)}
    let!(:alert_type_rating) do
      create :alert_type_rating,
        alert_type: alert.alert_type,
        rating_from: 1,
        rating_to: 6,
        management_dashboard_table_active: management_tables_active
    end
    let!(:content_version){ create :alert_type_rating_content_version, alert_type_rating: alert_type_rating }

    let(:management_tables_active){ true }

    context 'where the rating matches the range' do

      it 'creates a management dashboard table pairing the alert and the content for each active dashboard' do
        service.perform(school.latest_alerts_without_exclusions)
        expect(content_generation_run.management_dashboard_tables.count).to be 1

        table = content_generation_run.management_dashboard_tables.first
        expect(table.alert).to eq(alert)
        expect(table.content_version).to eq(content_version)
      end

      it 'does not create any tables if there is an alert type exception' do
        SchoolAlertTypeExclusion.create(school: school, alert_type: alert.alert_type)
        expect { service.perform(school.latest_alerts_without_exclusions)}.to change { content_generation_run.management_dashboard_tables.count }.by(0)
      end

      context 'where the management tables are not active' do
        let(:management_tables_active){ false }
        it 'does not include the alert' do
          service.perform(school.latest_alerts_without_exclusions)
          expect(content_generation_run.management_dashboard_tables.count).to be 0
        end
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Navigation::AdminDashboardComponent, :include_url_helpers, type: :component do
  subject(:component) do
    described_class.new(**params)
  end

  let(:current_user) { create(:admin) }

  let(:params) do
    { current_user: }
  end

  context 'when rendering' do
    before do
      render_inline(component)
    end

    it { expect(page).to have_link('Dashboard Home', href: admin_dashboard_path(current_user)) }

    describe 'my x links' do
      it 'links to school groups' do
        expect(page).to have_link('My School Groups',
                                  href: admin_dashboard_school_groups_path(current_user))
      end

      it 'links to project groups' do
        expect(page).to have_link('My Project Groups',
                                  href: admin_dashboard_school_groups_path(current_user, group_type: 'project'))
      end

      it 'links to impact reports' do
        expect(page).to have_link('My Impact Reports',
                                  href: admin_dashboard_impact_reports_path(current_user))
      end

      it 'links to data sources' do
        expect(page).to have_link('My Data Sources',
                                  href: admin_dashboard_data_sources_path(current_user))
      end

      it 'links to suppliers' do
        expect(page).to have_link('My Suppliers',
                                  href: admin_dashboard_suppliers_path(current_user))
      end

      it 'links to data feeds' do
        expect(page).to have_link('My Data Feeds',
                                  href: admin_dashboard_amr_data_feed_configs_path(current_user))
      end

      it 'links to issues' do
        expect(page).to have_link('My Issues',
                                  href: admin_dashboard_issues_path(current_user))
      end

      it 'links to energy tariffs' do
        expect(page).to have_link('My Energy Tariffs',
                                  href: admin_dashboard_energy_tariffs_path(current_user))
      end

      describe 'my schools section' do
        it 'has the correct links' do # rubocop:disable RSpec/MultipleExpectations, RSpec/ExampleLength
          expect(page).to have_link('Onboarding',
                                    href: admin_dashboard_school_onboardings_path(current_user))
          expect(page).to have_link('Awaiting activation',
                                    href: admin_dashboard_activations_path(current_user))
          expect(page).to have_link('Recently onboarded',
                                    href: completed_admin_dashboard_school_onboardings_path(current_user))
          expect(page).to have_link('Engaged schools',
                                    href: admin_dashboard_engaged_groups_path(current_user))
          expect(page).to have_link('Recent activities',
                                    href: admin_dashboard_activities_path(current_user))
          expect(page).to have_link('Recent actions',
                                    href: admin_dashboard_interventions_path(current_user))
          expect(page).to have_link('Missing alert contacts',
                                    href: admin_dashboard_missing_alert_contacts_path(current_user))
          expect(page).to have_link('Pupil number updates',
                                    href: admin_dashboard_pupil_number_updates_path(dashboard_id: current_user,
                                                                                    admin: current_user))
        end
      end

      describe 'my meters section' do
        # rubocop:disable Layout/LineLength
        it 'has the correct links' do
          expect(page).to have_link('New data for inactive meters',
                                    href: admin_dashboard_new_data_inactive_meter_report_index_path(dashboard_id: current_user, admin: current_user))
          expect(page).to have_link('Baseload anomalies',
                                    href: admin_dashboard_baseload_anomaly_index_path(dashboard_id: current_user, admin: current_user))
          expect(page).to have_link('Manually read meters',
                                    href: admin_dashboard_manual_reads_path(dashboard_id: current_user, admin: current_user))
        end
        # rubocop:enable Layout/LineLength
      end
    end
  end
end

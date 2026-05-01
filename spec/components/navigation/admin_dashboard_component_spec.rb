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
      it 'has the correct links' do
        expect(page).to have_link('My School Groups',
                                  href: admin_dashboard_school_groups_path(current_user))
        expect(page).to have_link('My Project Groups',
                                  href: admin_dashboard_school_groups_path(current_user, group_type: 'project'))
        expect(page).to have_link('My Data Sources',
                                  href: admin_dashboard_data_sources_path(current_user))
        expect(page).to have_link('My Data Feeds',
                                  href: admin_dashboard_amr_data_feed_configs_path(current_user))
        expect(page).to have_link('My Issues',
                                  href: admin_dashboard_issues_path(current_user))
      end

      describe 'my_schools section' do
        it 'has the correct links' do #  rubocop:disable RSpec/MultipleExpectations
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
        end
      end
    end
  end
end

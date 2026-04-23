# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin dashboard' do
  let(:user) { nil }

  before do
    sign_in(user) if user.present?
  end

  describe 'Unauthorized access' do
    before do
      visit admin_dashboards_url
    end

    context 'when not logged in' do
      it { expect(page).to have_content('You need to sign in or sign up before continuing.') }
    end

    context 'when signed in as a non-admin user' do
      let(:user) { create(:staff) }

      it 'does not allow access' do
        expect(page).to have_content('You are not authorized to view that page.')
      end
    end
  end

  describe 'Authorized access' do
    let!(:user) { create(:admin, name: 'admin user') }

    before do
      visit admin_dashboards_url
    end

    describe 'index page' do
      let(:staff_user) { create(:staff) }

      it 'displays a list of links to admin users' do
        expect(page).to have_link(user.name, href: admin_dashboard_path(user))
      end

      it 'does not display non-admin users' do
        expect(page).to have_no_content(staff_user.name)
      end
    end

    describe 'Individual dashboard' do
      before do
        click_on user.name
      end

      it 'has breadcrumbs' do
        expect(page).to have_link('Admin', href: admin_path)
        expect(page).to have_link('Dashboards', href: admin_dashboards_path)
      end

      describe 'navigation' do
        it { expect(page).to have_css('.navigation-admin-dashboard-component') }

        # rubocop:disable RSpec/NestedGroups

        describe 'my school groups' do
          let!(:user_school_group) { create(:school_group, default_issues_admin_user: user) }
          let!(:non_user_school_group) { create(:school_group) }

          before do
            click_on 'My School Groups'
          end

          it 'links to the school groups page' do
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups")
          end

          it 'displays school groups belonging to the user' do
            expect(page).to have_content(user_school_group.name)
          end

          it 'does not display school groups which do not belong to the user' do
            expect(page).to have_no_content(non_user_school_group.name)
          end
        end

        describe 'my project groups' do
          let!(:user_project_group) { create(:school_group, group_type: 'project', default_issues_admin_user: user) }
          let!(:non_user_project_group) { create(:school_group, group_type: 'project') }

          before do
            click_on 'My Project Groups'
          end

          it 'links to the project groups page' do
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups?group_type=project")
          end

          it 'displays project groups belonging to the user' do
            expect(page).to have_content(user_project_group.name)
          end

          it 'does not display project groups which do not belong to the user' do
            expect(page).to have_no_content(non_user_project_group.name)
          end
        end

        describe 'my data sources' do
          let!(:user_data_source) { create(:data_source, owned_by: user) }
          let!(:non_user_data_source) { create(:data_source) }

          before do
            click_on 'My Data Sources'
          end

          it 'links to the data sources page' do
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/data_sources")
          end

          it 'displays data sources belonging to the user' do
            expect(page).to have_content(user_data_source.name)
          end

          it 'does not display data sources which do not belong to the user' do
            expect(page).to have_no_content(non_user_data_source.name)
          end
        end

        describe 'my data feeds' do
          let!(:user_data_feed) { create(:amr_data_feed_config, owned_by: user) }
          let!(:non_user_data_feed) { create(:amr_data_feed_config) }

          before do
            click_on 'My Data Feeds'
          end

          it 'links to the data feeds page' do
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/amr_data_feed_configs")
          end

          it 'displays data feeds belonging to the user' do
            expect(page).to have_content(user_data_feed.description)
          end

          it 'does not display data feeds which do not belong to the user' do
            expect(page).to have_no_content(non_user_data_feed.description)
          end
        end

        describe 'my issues' do
          let!(:user_issue) { create(:issue, owned_by: user) }
          let!(:non_user_issue) { create(:issue) }

          before do
            click_on 'My Issues'
          end

          it 'links to the issues page' do
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/issues")
          end

          it 'displays issues belonging to the user' do
            expect(page).to have_content(user_issue.name)
          end

          it 'does not display issues which do not belong to the user' do
            expect(page).to have_no_content(non_user_issue.name)
          end
        end

        describe 'my schools' do
          let(:user_school_group) { create(:school_group, default_issues_admin_user: user) }
          let(:non_user_school_group) { create(:school_group) }

          describe 'onboarding' do
            let!(:user_onboarding) do
              create(:school_onboarding, school_name: 'user school', school_group_id: user_school_group.id)
            end

            let!(:non_user_onboarding) do
              create(:school_onboarding, school_name: 'non user school', school_group_id: non_user_school_group.id)
            end

            before do
              click_on 'Onboarding'
            end

            it 'links to the onboarding page' do
              expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_setup")
            end

            it 'displays onboarding schools in user school groups' do
              expect(page).to have_content(user_onboarding.school_name)
            end

            it 'does not display onboarding schools not in user school groups' do
              puts page.html
              expect(page).to have_no_content(non_user_onboarding.school_name)
            end
          end

          describe 'awaiting activation' do
            let!(:user_awaiting_school) do
              create(:school, school_group: user_school_group, active: true, visible: false)
            end

            let!(:non_user_awaiting_school) do
              create(:school, school_group: non_user_school_group, active: true, visible: false)
            end

            before do
              click_on 'Awaiting activation'
            end

            it 'links to the activations page' do
              expect(page).to have_current_path("/admin/dashboards/#{user.id}/activations")
            end

            it 'displays schools awaiting activation in user school groups' do
              expect(page).to have_content(user_awaiting_school.name)
            end

            it 'does not display schools awaiting activation which are not in user school groups' do
              expect(page).to have_no_content(non_user_awaiting_school.name)
            end
          end

          describe 'recently onboarded' do
            let!(:user_onboarding) do
              create(:school_onboarding,
                     :with_events,
                     :with_school,
                     school_name: 'User school',
                     event_names: %i[email_sent onboarding_complete],
                     school_group_id: user_school_group.id)
            end

            let!(:non_user_onboarding) do
              create(:school_onboarding,
                     :with_events,
                     :with_school,
                     school_name: 'Non user school',
                     event_names: %i[email_sent onboarding_complete],
                     school_group_id: non_user_school_group.id)
            end

            let!(:old_user_onboarding) do
              create(:school_onboarding,
                     :with_school,
                     :with_completed,
                     school_name: 'Old user school',
                     completed_on: 61.days.ago,
                     school_group_id: user_school_group.id)
            end

            before do
              click_on 'Recently onboarded'
            end

            it 'links to the recently onboarded report' do
              expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_setup/completed")
            end

            it 'displays onboardings for user school groups' do
              expect(page).to have_content(user_onboarding.school_name)
            end

            it 'does not display onboarding for other school groups' do
              expect(page).to have_no_content(non_user_onboarding.school_name)
            end

            it 'does not display onboardings older than 60 days' do
              expect(page).to have_no_content(old_user_onboarding.school_name)
            end
          end

          describe 'recent activities' do
            let!(:activity_type) { create(:activity_type) }
            let!(:user_school) { create(:school, school_group: user_school_group) }
            let!(:non_user_school) { create(:school, school_group: non_user_school_group) }
            let!(:user_activity) do
              create(:activity, school: user_school, activity_type: activity_type, title: 'user activity')
            end
            let!(:non_user_activity) do
              create(:activity, school: non_user_school, activity_type: activity_type, title: 'non user activity')
            end

            before do
              click_on 'Recent activities'
            end

            it 'links to the activities report' do
              expect(page).to have_current_path("/admin/dashboards/#{user.id}/activities")
            end

            it 'displays activities from schools in user school groups' do
              expect(page).to have_content(user_activity.title)
            end

            it 'does not display activities for other schools' do
              expect(page).to have_no_content(non_user_activity.title)
            end
          end

          describe 'recent actions' do
            let!(:user_intervention) do
              create(:observation, :intervention, school_id: create(:school, school_group: user_school_group).id)
            end

            let!(:non_user_intervention) do
              create(:observation, :intervention, school: create(:school, school_group: non_user_school_group))
            end

            before do
              click_on 'Recent actions'
            end

            it 'links to the interventions report' do
              expect(page).to have_current_path("/admin/dashboards/#{user.id}/interventions")
            end

            it 'displays actions for user school groups' do
              expect(page).to have_content(user_intervention.intervention_type.name)
            end

            it 'does not display actions for other non-user school groups' do
              expect(page).to have_no_content(non_user_intervention.intervention_type.name)
            end
          end
        end

        # rubocop:enable RSpec/NestedGroups
      end

      describe 'quick links' do
        let!(:school_group) do
          create(:school_group, :with_active_schools, default_issues_admin_user: user)
        end

        let!(:school) { create(:school, school_group:) }

        before do
          visit admin_dashboard_url(user)
        end

        it { expect(page).to have_css('.admin-quick-links-component') }

        it 'links to the school group page' do
          within '#school_group-form' do
            select school_group.name, from: :school_group
            click_on 'Manage'
          end

          expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups/#{school_group.slug}")
        end

        it 'links to the MPXN page' do
          within '#mpxn-form' do
            fill_in 'mpxn', with: '1234'
            click_on 'Find MPXN'
          end

          expect(page).to have_current_path('/admin/find_school_by_mpxn?query=1234&commit=Find+MPXN')
        end

        it 'links to the school page' do
          within '#school-form' do
            select school.name, from: :school
            click_on 'Manage'
          end

          expect(page).to have_current_path("/schools/#{school.slug}/meters")
        end

        it 'links to the URN page' do
          within '#urn-form' do
            fill_in 'urn', with: '1234'
            click_on 'Find URN'
          end

          expect(page).to have_current_path('/admin/find_school_by_urn?query=1234&commit=Find+URN')
        end
      end

      describe 'dashboard prompts' do
        it { expect(page).to have_css('.admin-dashboard-prompt-component') }
      end
    end
  end
end

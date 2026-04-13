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
    let!(:user) { create(:admin, name: 'username') }

    before do
      visit admin_dashboards_url
    end

    describe 'Viewing index page' do
      let(:staff_user) { create(:staff) }

      it 'displays a list of links to admin users' do
        expect(page).to have_link('username', href: admin_dashboard_path(user))
      end

      it 'does not display non-admin users' do
        expect(page).to have_no_content(staff_user.name)
      end

      describe 'Individual dashboard' do
        it 'has breadcrumbs' do
          click_on user.name
          expect(page).to have_link('Admin', href: admin_path)
          expect(page).to have_link('Dashboards', href: admin_dashboards_path)
        end

        # rubocop:disable RSpec/NestedGroups

        describe 'navigation' do
          let!(:user_school_group) { create(:school_group, default_issues_admin_user: user) }
          let!(:non_user_school_group) { create(:school_group) }

          before do
            click_on user.name
          end

          it { expect(page).to have_css('.navigation-admin-dashboard-component') }

          describe 'school group page' do
            before do
              click_on 'My School Groups'
            end

            it { expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups") }

            it 'displays school groups belonging to the user' do
              expect(page).to have_content(user_school_group.name)
            end

            it 'does not display school groups which do not belong to the user' do
              expect(page).to have_no_content(non_user_school_group.name)
            end
          end

          it 'navigates to the project group page' do
            click_on 'My Project Groups'
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups?group_type=project")
          end

          it 'navigates to the data sources page' do
            click_on 'My Data Sources'
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/data_sources")
          end

          it 'navigates to the data feeds page' do
            click_on 'My Data Feeds'
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/amr_data_feed_configs")
          end

          it 'navigates to the issues page' do
            click_on 'My Issues'
            expect(page).to have_current_path("/admin/dashboards/#{user.id}/issues")
          end
        end

        describe 'quick links' do
          let!(:school_group) do
            create(:school_group, :with_active_schools, default_issues_admin_user: user)
          end

          let!(:school) { create(:school, school_group:) }

          before do
            click_on user.name
          end

          it { expect(page).to have_css('.admin-quick-links-component') }

          it 'navigates to the school group page' do
            within '#school_group-form' do
              select school_group.name, from: :school_group
              click_on 'Manage'
            end

            expect(page).to have_current_path("/admin/dashboards/#{user.id}/school_groups/#{school_group.slug}")
          end

          it 'navigates to the MPXN page' do
            within '#mpxn-form' do
              fill_in 'mpxn', with: '1234'
              click_on 'Find MPXN'
            end

            expect(page).to have_current_path('/admin/find_school_by_mpxn?query=1234&commit=Find+MPXN')
          end

          it 'navigates to the school page' do
            within '#school-form' do
              select school.name, from: :school
              click_on 'Manage'
            end

            expect(page).to have_current_path("/schools/#{school.slug}/meters")
          end

          it 'navigates to the URN page' do
            within '#urn-form' do
              fill_in 'urn', with: '1234'
              click_on 'Find URN'
            end

            expect(page).to have_current_path('/admin/find_school_by_urn?query=1234&commit=Find+URN')
          end
        end

        # rubocop:enable RSpec/NestedGroups
      end
    end
  end
end

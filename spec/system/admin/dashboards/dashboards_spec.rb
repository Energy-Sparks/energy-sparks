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
    let(:user) { create(:admin, name: 'username') }

    before do
      visit admin_dashboards_url
    end

    context 'when viewing index page' do
      let(:staff_user) { create(:staff) }

      it 'displays a list of links to admin users' do
        expect(page).to have_link('username', href: admin_dashboard_path(user))
      end

      it 'does not display non-admin users' do
        expect(page).to have_no_content(staff_user.name)
      end
    end

    context 'when viewing an individual dashboard' do
      before do
        visit admin_dashboards_url
        click_on 'username'
      end

      it 'has breadcrumbs' do
        expect(page).to have_link('Admin', href: admin_path)
        expect(page).to have_link('Dashboards', href: admin_dashboards_path)
      end

      it { expect(page).to have_content(user.name) }

      describe 'managing school groups' do
        let!(:user_school_group) { create(:school_group, default_issues_admin_user: user) }
        let!(:non_user_school_group) { create(:school_group) }

        before do
          click_on 'School Groups'
        end

        it 'adds the relevant breadcrumb' do
          expect(page).to have_link(user.name, href: admin_dashboard_path(user))
        end

        it 'displays school groups associated with the dashboard user' do
          expect(page).to have_content(user_school_group.name)
        end

        it 'does not show school groups not associated with the dashboard user' do
          expect(page).to have_no_content(non_user_school_group.name)
        end

        it 'has a link to manage school group' do
          expect(page).to have_link('Manage')
        end
      end

      describe 'managing one school group' do
        let!(:user_school_group) { create(:school_group, default_issues_admin_user: user) }

        before do
          click_on 'School Groups'
          click_on 'Manage', id: user_school_group.slug
        end

        it 'adds the relevant breadcrumb' do
          expect(page).to have_link('School Groups', href: admin_dashboard_school_groups_path(dashboard_id: user.id))
        end

        it 'has the correct path' do
          expect(page).to have_current_path(
            admin_dashboard_school_group_path(dashboard_id: user.id, id: user_school_group.id)
          )
        end
      end
    end
  end
end

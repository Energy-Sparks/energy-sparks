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

      describe 'Viewing an individual dashboard' do
        before do
          click_on 'username'
        end

        it 'has breadcrumbs' do
          expect(page).to have_link('Admin', href: admin_path)
          expect(page).to have_link('Dashboards', href: admin_dashboards_path)
        end

        it { expect(page).to have_content(user.name) }
      end
    end
  end
end

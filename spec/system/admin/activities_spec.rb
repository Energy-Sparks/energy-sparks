# frozen_string_literal: true

require 'rails_helper'

describe 'Admin activities home page' do
  context 'when not signed in' do
    before { visit admin_activities_root_path }

    it 'is admin only' do
      expect(page).to have_text('You need to sign in or sign up before continuing.')
    end
  end

  context 'when signed in as admin' do
    before do
      sign_in create(:admin)
      visit admin_activities_root_path
    end

    it 'shows the activities and actions home page' do
      expect(page).to have_text('Activities and Actions')
    end

    it 'renders the left nav' do
      within '#page-navigation' do
        expect(page).to have_link('Overview', href: admin_activities_root_path)
        expect(page).to have_text('Activities')
        expect(page).to have_text('Actions')
        expect(page).to have_text('Related')
      end
    end

    describe 'activities section' do
      it { expect(page).to have_text('Activities') }
      it { expect(page).to have_link('Manage', href: admin_activity_types_path) }
      it { expect(page).to have_text('Categories') }
      it { expect(page).to have_link('Manage', href: admin_activity_categories_path) }
      it { expect(page).to have_text('Classifications') }
      it { expect(page).to have_link('Manage', href: admin_activities_labels_path(label_type: 'aim')) }
      it { expect(page).to have_text('Latest Recordings') }
      it { expect(page).to have_link('View', href: admin_reports_activities_path) }
      it { expect(page).to have_text('Report') }
      it { expect(page).to have_link('View', href: admin_reports_activity_types_path) }
    end

    describe 'actions section' do
      it { expect(page).to have_text('Actions') }
      it { expect(page).to have_link('Manage', href: admin_intervention_types_path) }
      it { expect(page).to have_text('Categories') }
      it { expect(page).to have_link('Manage', href: admin_intervention_type_groups_path) }
      it { expect(page).to have_text('Classifications') }
      it { expect(page).to have_link('Manage', href: admin_activities_labels_path(label_type: 'focus')) }
      it { expect(page).to have_text('Latest Recordings') }
      it { expect(page).to have_link('View', href: admin_reports_interventions_path) }
      it { expect(page).to have_text('Report') }
      it { expect(page).to have_link('View', href: admin_reports_intervention_types_path) }
    end

    describe 'programmes section' do
      it { expect(page).to have_text('Programmes') }
      it { expect(page).to have_link('Manage', href: admin_programme_types_path) }
    end

    describe 'related section' do
      it { expect(page).to have_text('Advice pages') }
      it { expect(page).to have_link('Manage', href: admin_advice_pages_path) }
      it { expect(page).to have_text('Alerts') }
      it { expect(page).to have_link('Manage', href: admin_alert_types_path) }
      it { expect(page).to have_text('Audits') }
      it { expect(page).to have_link('View', href: admin_reports_recent_audits_path) }
      it { expect(page).to have_text('Recent images') }
      it { expect(page).to have_link('View', href: admin_reports_images_path) }
    end
  end

  context 'when signed in as a non-admin user' do
    before do
      sign_in create(:staff)
      visit admin_activities_root_path
    end

    it 'redirects away' do
      expect(page).to have_no_text('Activities and Actions')
      expect(page).to have_no_current_path(admin_activities_root_path, ignore_query: true)
    end
  end
end

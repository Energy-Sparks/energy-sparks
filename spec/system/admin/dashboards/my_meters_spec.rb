# frozen_string_literal: true

require 'rails_helper'

describe 'Admin dashboard - My Meters' do
  let(:user) { create(:admin, name: 'admin user', operations: true) }
  let(:link) { nil }

  before do |example|
    sign_in(user)
    visit admin_dashboards_url
    click_on user.name
    click_on link || example.example_group.description
  end

  describe 'New data for inactive meters' do
    it 'links to the new data for inactive meter report filtered by user' do
      expect(page).to have_link('View all new data for inactive meters',
                                href: admin_reports_new_data_inactive_meter_report_index_path)
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/new_data_inactive_meter_report?admin=#{user.id}")
    end
  end

  describe 'Baseload anomalies' do
    it 'links to the baseload anomalies report filtered by user' do
      expect(page).to have_link('View all baseload anomalies', href: admin_reports_baseload_anomaly_index_path)
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/baseload_anomaly?admin=#{user.id}")
    end
  end

  describe 'Manually read meters' do
    it 'links to the manual reads report filtered by user' do
      expect(page).to have_link('View all manual reads', href: admin_reports_manual_reads_path)
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/manual_reads?admin=#{user.id}")
    end
  end

  describe 'Estimated data' do
    it 'links to the estimated data report filtered by user' do
      expect(page).to have_link('View all estimated reads', href: admin_reports_estimated_reads_path)
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/estimated_reads?admin=#{user.id}")
    end
  end

  describe 'Limited data meters' do
    it 'has the correct path' do
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/limited_data?admin=#{user.id}")
    end

    it 'links to the reports' do
      expect(page).to have_link('View all limited data meters', href: admin_reports_limited_data_path)
    end

    it_behaves_like 'an admin meter import report', data: false do
      let(:link) { 'Limited data meter' }
    end
  end

  describe 'Stale data meters' do
    it 'has the correct path' do
      expect(page).to have_current_path("/admin/dashboards/#{user.id}/stale_data?admin=#{user.id}")
    end

    it 'links to the reports' do
      expect(page).to have_link('View all stale data meters', href: admin_reports_stale_data_path)
    end

    it_behaves_like 'an admin meter import report', data: false do
      let(:link) { 'Stale data meter' }
    end
  end
end

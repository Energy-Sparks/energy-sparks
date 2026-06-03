# frozen_string_literal: true

require 'rails_helper'

describe 'Lagging Meters Report', :include_application_helper do
  let(:latest_reading_date) { 9.days.ago }
  let!(:gas_meter) do
    create(:gas_meter_with_validated_reading_dates,
           school: create(:school, :with_school_group),
           start_date: 20.days.ago,
           end_date: latest_reading_date,
           data_source: create(:data_source, import_warning_days: 5))
  end

  let(:page_title) { 'Stale data' }

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on page_title
  end

  it_behaves_like 'an admin meter report' do
    let(:title) { page_title }
    let(:description) { 'List of meters that have stale data' }
  end

  it_behaves_like 'an admin meter import report' do
    let(:meter) { gas_meter}
    let(:end_date) { latest_reading_date}
  end
end

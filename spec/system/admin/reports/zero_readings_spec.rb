# frozen_string_literal: true

require 'rails_helper'

describe 'Zero Readings Report', :include_application_helper do
  let(:latest_reading_date) { 2.days.ago }
  let!(:gas_meter) do
    meter = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
           school: create(:school, :with_school_group),
           start_date: 20.days.ago,
           end_date: latest_reading_date,
           data_source: create(:data_source, import_warning_days: 5),
           log: create(:amr_data_feed_import_log,
                       amr_data_feed_config: create(:amr_data_feed_config),
                       import_time: Time.zone.today))
    meter.amr_data_feed_readings.last.update!(readings: Array.new(48, 0))
    meter
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Zero readings'
  end

  it_behaves_like 'an admin meter report', help: false do
    let(:title) { 'Meters with recent zero readings' }
    let(:description) { 'Meters where we have received one or more days of entirely zero readings in the last 24 hours' }
  end

  it_behaves_like 'an admin meter import report' do
    let(:meter) { gas_meter}
    let(:end_date) { latest_reading_date}
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'New data for inactive meters', :include_application_helper do
  let(:latest_reading_date) { 2.days.ago }
  let(:admin_meter_status) { create(:admin_meter_status, ignore_in_inactive_meter_report: false) }
  let(:active) { false }

  let!(:gas_meter) do
    meter = create(:gas_meter_with_validated_reading_dates, :with_unvalidated_readings,
           active: active,
           school: create(:school, :with_school_group),
           start_date: 20.days.ago,
           end_date: latest_reading_date,
           admin_meter_status: admin_meter_status,
           data_source: create(:data_source, import_warning_days: 5),
           log: create(:amr_data_feed_import_log,
                       amr_data_feed_config: create(:amr_data_feed_config),
                       import_time: Time.zone.today))
    meter.amr_data_feed_readings.last.update!(readings: Array.new(48, ''))
    meter
  end

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'New data for inactive meters'
  end

  it_behaves_like 'an admin meter report', help: true do
    let(:title) { 'New data for inactive meters' }
    let(:description) { 'List of inactive meters for which we have loaded unvalidated readings in the last 30 days' }
  end

  it_behaves_like 'an admin meter import report' do
    let(:meter) { gas_meter}
    let(:end_date) { latest_reading_date}
  end

  context 'when status is ignored' do
    let(:admin_meter_status) { create(:admin_meter_status, ignore_in_inactive_meter_report: true) }

    it { expect(page).not_to have_content(gas_meter.name) }
  end

  context 'when meter is active' do
    let(:active) { true }

    it { expect(page).not_to have_content(gas_meter.name) }
  end

  context 'when no unvalidated readings' do
    let!(:gas_meter) do
      create(:gas_meter_with_validated_reading_dates,
             active: active,
             school: create(:school, :with_school_group),
             start_date: 20.days.ago,
             end_date: latest_reading_date,
             admin_meter_status: admin_meter_status,
             data_source: create(:data_source, import_warning_days: 5))
    end

    it { expect(page).not_to have_content(gas_meter.name) }
  end
end

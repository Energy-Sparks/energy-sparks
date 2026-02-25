# frozen_string_literal: true

require 'rails_helper'

describe 'Baseload anomaly report' do
  let(:school_group) { create(:school_group, default_issues_admin_user: create(:admin)) }
  let(:meter) { create(:electricity_meter, school: create(:school, school_group: school_group)) }

  let(:reading_date) { Date.yesterday }
  let(:page_title) { 'Baseload anomalies' }

  before do
    create(:amr_validated_reading, meter: meter, reading_date: reading_date - 1, kwh_data_x48: Array.new(48, 10.0))
    create(:amr_validated_reading, meter: meter, reading_date: reading_date, kwh_data_x48: Array.new(48, 0.0))
    Report::BaseloadAnomaly.refresh
    sign_in(create(:admin))
    visit admin_reports_path
    click_on page_title
  end

  it_behaves_like 'an admin meter report' do
    let(:title) { page_title }
    let(:description) { 'Shows sudden changes in baseload for active electricity meters over the last 30 days.' }
    let(:frequency) { :daily }
  end

  it 'displays the table' do
    rows = all('tr').map { |tr| tr.all('th, td').map(&:text) }
    expect(rows).to eq([
                         ['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Reading Date', 'Previous Baseload', 'Baseload', 'Chart'],
                         [meter.school_group.name, meter.school_group&.default_issues_admin_user&.name, meter.school.name, meter.mpan_mprn.to_s, meter.name, reading_date.iso8601, '20', '0', 'Chart']
                       ])
  end

  it 'allows csv download' do
    click_on 'CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq("School Group,Admin,School,Meter,Meter Name,Reading Date,Previous Baseload,Baseload,Chart\n" \
         "#{meter.school_group.name},#{meter.school_group&.default_issues_admin_user&.name},#{meter.school.name},#{meter.mpan_mprn},#{meter.name},#{reading_date},20,0,#{analysis_school_advice_baseload_url(meter.school, host: 'example.com')}\n")
  end
end

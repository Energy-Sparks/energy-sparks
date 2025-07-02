# frozen_string_literal: true

require 'rails_helper'

describe 'Lagging Meters Report', :include_application_helper do
  let(:end_date)         { 9.days.ago }
  let!(:meter) do
    create(:gas_meter_with_validated_reading_dates,
           school: create(:school, :with_school_group),
           start_date: 20.days.ago,
           end_date: end_date,
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

  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to \
      eq([
           ['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
            'Meter Type', 'Meter System', 'Data Source', 'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date',
            'Issues & Notes'],
           [
             meter.school.school_group.name, '', meter.school.name, meter.mpan_mprn.to_s, meter.name,
             '', meter.t_meter_system, meter.data_source&.name, '', '', 'N', nice_dates(end_date),
             ''
           ]
         ])
  end

  it 'allows csv download' do
    click_on 'CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    header = ['School Group', 'Admin', 'School', 'Meter', 'Meter Name',
              'Meter Type', 'Meter System', 'Data Source', 'Procurement Route', 'Meter Status', 'Manual Reads', 'Last Validated Date',
              'Issues',
              'Notes'
            ]
    expect(body).to \
      eq("#{header.join(',')}\n" \
         "#{meter.school.school_group.name},,#{meter.school.name},#{meter.mpan_mprn},#{meter.name},gas,#{meter.t_meter_system},#{meter.data_source&.name},,,N,#{end_date.to_date.iso8601},0,0\n")
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe 'DCC Status Report' do
  let(:status) { create(:admin_meter_status) }
  let!(:meter) { create(:gas_meter, admin_meter_status: status, dcc_meter: :smets2) }

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    stub_request(:get, 'https://n3rgy.test/?maxResults=100&startAt=0').to_return(status: 400)
    click_on 'DCC meter status'
  end

  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
      [
        ['School Name', 'Group Name', 'School Removed?', 'Group Owner', 'Type',
         'Supplier', 'Data Source', 'MPAN', 'Meter Name', 'Active?', 'Consented?', 'Meter System',
         'N3rgy Meter Type', 'Meter Status', 'Earliest Validated', 'Latest Validated', 'Issues'],
        [
          meter.school.name, '', 'No', '', '',
          '', '', meter.mpan_mprn.to_s, meter.name, 'Yes', 'No', 'NHH AMR',
          'Smets2', meter.admin_meter_status_label, '', '', ''
        ]
      ]
    )
  end

  it 'allows csv download' do
    click_on 'Download as CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq('School Name,Group Name,School Removed?,Group Owner,Type,Supplier,Data Source,MPAN,Meter Name,Active?,' \
         "Consented?,Meter System,N3rgy Meter Type,Meter Status,Earliest Validated,Latest Validated,Issues\n" \
         "#{meter.school.name},,No,,Gas,,,#{meter.mpan_mprn},#{meter.name},Yes,No,NHH AMR,Smets2," \
         "#{meter.admin_meter_status_label},,,0\n")
  end
end

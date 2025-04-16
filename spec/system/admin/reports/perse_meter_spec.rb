# frozen_string_literal: true

require 'rails_helper'

describe 'Perse meter report' do
  let!(:meter) { create(:gas_meter, perse_api: :half_hourly) }

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Perse meter summary'
  end

  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to eq(
      [
        ['School Name', 'Group Name', 'School Archived?', 'Group Owner', 'Type', 'Data Source', 'MPAN', 'Meter Name',
         'Active?', 'Earliest Validated', 'Latest Validated', 'Issues'],
        [meter.school.name, '', 'No', '', '', '', meter.mpan_mprn.to_s, meter.name, 'Yes', '', '', '']
      ]
    )
  end

  it 'allows csv download' do
    click_on 'Download as CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq('School Name,Group Name,School Archived?,Group Owner,Type,Data Source,MPAN,Meter Name,Active?,' \
         "Earliest Validated,Latest Validated,Issues\n" \
         "#{meter.school.name},,No,,Gas,,#{meter.mpan_mprn},#{meter.name},Yes,,,0\n")
  end
end

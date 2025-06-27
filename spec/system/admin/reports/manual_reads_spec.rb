# frozen_string_literal: true

require 'rails_helper'

describe 'Manual Reads Report' do
  let!(:meter) { create(:gas_meter, school: create(:school, :with_school_group), manual_reads: true) }

  before do
    sign_in(create(:admin))
    visit admin_reports_path
    click_on 'Manual reads meter report'
  end

  it 'displays the table' do
    expect(all('tr').map { |tr| tr.all('th, td').map(&:text) }).to \
      eq([['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Meter Type', 'Data Source', 'Last Validated Date',
           'Issues & Notes', 'Issues', 'Notes'],
          [meter.school.school_group.name, '', meter.school.name, meter.mpan_mprn.to_s, meter.name, 'gas', '', '', '', '0', '0']])
  end

  it 'allows csv download' do
    click_on 'CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq("School Group,Admin,School,Meter,Meter Name,Meter Type,Data Source,Last Validated Date,Issues,Notes\n" \
         "#{meter.school.school_group.name},,#{meter.school.name},#{meter.mpan_mprn},#{meter.name},gas,,,0,0\n")
  end
end

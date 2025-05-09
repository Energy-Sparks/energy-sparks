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
      eq([['Group Name', 'School Name', 'Group Owner', 'MPAN', 'Meter Type', 'Data Source', 'Last Validated Date',
           'Issues & Notes'],
          [meter.school.school_group.name, meter.school.name, '', meter.mpan_mprn.to_s, 'gas', '', '', '']])
  end

  it 'allows csv download' do
    click_on 'Download as CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq("Group Name,School Name,Group Owner,MPAN,Meter Type,Data Source,Last Validated Date,Issues,Notes\n" \
         "#{meter.school.school_group.name},#{meter.school.name},,#{meter.mpan_mprn},gas,,,0,0\n")
  end
end

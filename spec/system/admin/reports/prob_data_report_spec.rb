require 'rails_helper'

describe 'Prob Data Report', type: :system do
  let!(:school) do
    create(:school, school_group: create(:school_group, default_issues_admin_user: create(:admin)))
  end

  let(:page_title) { 'PROB data report' }

  let!(:meter) do
    create(:gas_meter_with_validated_reading_dates,
      school: school,
      start_date: Time.zone.today - 5,
      end_date: Time.zone.today,
      status: 'PROB')
  end

  before do
    sign_in(create(:admin))
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
    click_on page_title
  end

  it_behaves_like 'an admin meter report', help: false do
    let(:title) { page_title }
    let(:description) { 'Lists all of the meters in the system that have one or more "PROB" data readings' }
  end

  it 'displays the table' do
    rows = all('tr').map { |tr| tr.all('th, td').map(&:text) }
    expect(rows).to eq([
                         ['School Group', 'Admin', 'School', 'Meter', 'Meter Name', 'Meter Type', 'Count'],
                         [meter.school_group.name, meter.school_group&.default_issues_admin_user&.name, meter.school.name, meter.mpan_mprn.to_s, meter.name, '', '6']
                       ])
  end

  it 'allows csv download' do
    click_on 'CSV'
    expect(page.response_headers['content-type']).to eq('text/csv')
    expect(body).to \
      eq("School Group,Admin,School,Meter,Meter Name,Meter Type,Count\n" \
         "#{meter.school_group.name},#{meter.school_group&.default_issues_admin_user&.name},#{meter.school.name},#{meter.mpan_mprn},#{meter.name},#{meter.meter_type},6\n")
  end
end

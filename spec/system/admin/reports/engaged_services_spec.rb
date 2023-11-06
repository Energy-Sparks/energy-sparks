require 'rails_helper'

describe 'Engaged Schools Report', type: :system do
  let(:admin)         { create(:admin) }
  let!(:school)       { create(:school, :with_school_group, :with_points, active: true) }
  let(:last_sign_in)  { Time.zone.now }
  let!(:user)         { create(:school_admin, school: school, last_sign_in_at: last_sign_in)}

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'displays a report' do
    click_on 'Engaged Schools'
    expect(page).to have_content(school.school_group.name)
    expect(page).to have_link(school.name, href: school_path(school))
    expect(page).to have_link('1', href: school_timeline_path(school))
  end

  describe 'when downloading the CSV' do
    let(:lines) { page.body.lines.collect(&:chomp) }

    it 'provides a CSV download' do
      click_on 'Engaged Schools'
      click_on 'Download as CSV'
      expect(lines.first.split(',')).to eq ['School Group', 'School', 'Funder', 'Country', 'Activities', 'Actions', 'Programmes', 'Target?', 'Transport survey?', 'Temperatures?', 'Active users', 'Last visit']
      expect(lines.second.split(',')).to eq [school.school_group.name, school.name, '', school.country.humanize, '1', '0', '0', 'N', 'N', 'N', '1', last_sign_in.iso8601]

      expect(lines.count).to eq 2
    end
  end
end

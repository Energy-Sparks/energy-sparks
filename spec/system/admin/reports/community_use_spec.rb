require 'rails_helper'

describe 'Community Use Report', type: :system do
  let(:admin)                       { create(:admin) }
  let!(:community_use)              { create(:community_use) }

  before do
    sign_in(admin)
    visit root_path
    click_on 'Manage'
    click_on 'Reports'
  end

  it 'displays a report' do
    click_on 'Community use'
    expect(page).to have_link(community_use.school.name, href: school_path(community_use.school))
    expect(page).to have_content('Monday')
    expect(page).to have_content('Term Times')
    expect(page).to have_link('View', href: edit_school_times_path(community_use.school, id: 'community-use-section'))
  end
end

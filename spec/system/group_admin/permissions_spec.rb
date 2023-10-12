require 'rails_helper'

describe 'Group admin login and permissions' do
  let(:school_group) { create(:school_group) }
  let!(:school) { create(:school, school_group: school_group) }
  let(:group_admin) { create(:group_admin, school_group: school_group) }

  let(:other_school) { create(:school) }

  before(:each) do
    sign_in(group_admin)
  end

  it 'allows login and access to schools in the group' do
    visit root_path
    expect(page).to have_content(school_group.name)

    # click_on school.name
    first(:link, school.name).click

    click_on 'Edit school details'

    fill_in 'School name', with: 'New school name'
    click_on 'Update School'

    school.reload
    expect(school.name).to eq('New school name')

    visit school_path(other_school)
    expect(page).to_not have_content('Edit school details')
  end
end

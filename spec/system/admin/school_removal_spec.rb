require 'rails_helper'

RSpec.describe "school removal", :schools, type: :system do

  let(:school) { create(:school, name: 'My High School', visible: false) }
  let(:admin)  { create(:admin)}

  before(:each) do
    sign_in(admin)
  end

  it 'removes school and shows on removals list' do
    visit school_path(school)
    click_on 'Remove school'
    expect(page).to have_content('My High School REMOVAL')
    click_button 'Remove school'
    expect(page).to have_content('School has been removed')
    school.reload
    expect(school.active).to be_falsey

    visit admin_reports_path
    click_on 'Schools removed'
    expect(page).to have_content('My High School')
  end
end

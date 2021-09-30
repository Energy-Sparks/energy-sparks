require 'rails_helper'

describe 'school targets report', type: :system do

  let(:admin)              { create(:admin) }
  let!(:school_target_1)   { create(:school_target, electricity: 1.0, gas: 2.0, storage_heaters: 3.0) }
  let!(:school_target_2)   { create(:school_target) }

  before(:each) do
    sign_in(admin)
    visit admin_reports_path
  end

  it 'displays the report' do
    click_on "School targets"
    expect(page).to have_content("Listing 2 currently active school targets")
    expect(page).to have_content(school_target_1.school.name)
    expect(page).to have_content(school_target_1.electricity)
    expect(page).to have_content(school_target_1.gas)
    expect(page).to have_content(school_target_1.storage_heaters)
    expect(page).to have_link("View target", href: school_school_target_path(school_target_1.school, school_target_1))
  end
end

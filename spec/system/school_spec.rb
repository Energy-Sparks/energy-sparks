require 'rails_helper'

RSpec.describe "school", type: :system do
  it 'shows me a school page' do
    school_name = 'Oldfield Park Infants'
    FactoryBot.create(:school, name: school_name)
    visit root_path
    click_on('Schools')
    expect(page.has_content? "Participating Schools")
    click_on(school_name)
    expect(page.has_content? school_name)
  end
end

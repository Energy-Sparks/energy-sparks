require 'rails_helper'

describe 'managing school times' do
  let(:school_name) { 'Oldfield Park Infants'}
  let!(:school) { create_active_school(name: school_name)}
  let!(:admin)  { create(:admin)}

  before do
    sign_in(admin)
    visit school_path(school)
  end

  it 'allows setting of daily values and validates the inputs' do
    click_on 'Edit school times'

    expect(page).to have_content('Please note that while we will immediately save any changes')

    fill_in 'monday-opening_time', with: ''
    click_on 'Save school times'
    expect(page).to have_content("Opening time can't be blank")

    fill_in 'monday-opening_time', with: '900'
    click_on 'Save school times'

    expect(school.school_times.where(day: :monday).first.opening_time).to eq(900)

    expect(page).to have_content('School times have been updated')
  end
end

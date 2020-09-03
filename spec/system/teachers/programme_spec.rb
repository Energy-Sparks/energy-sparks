require 'rails_helper'

describe 'programme', type: :system do

  let(:school_name)       { 'Active school'}
  let(:other_school_name) { 'Bash Street' }
  let!(:school)           { create_active_school(name: school_name) }
  let!(:other_school)     { create_active_school(name: other_school_name) }
  let!(:user)             { create(:staff, school: school) }
  let!(:programme_type)   { create(:programme_type_with_activity_types) }

  let!(:inactive_programme_type) { create(:programme_type, active: false) }
  let!(:activity)  { create(:activity, school: school, activity_type: programme_type.activity_types.first ) }

  before do
    sign_in(user)
    visit root_path
    click_on 'Choose another programme'
  end

  it 'hides inactive programme types' do
    expect(page).to have_content(programme_type.title)
    expect(page).to_not have_content(inactive_programme_type.title)
  end

  it 'allows the user see details of a programme' do
    click_on programme_type.title
    expect(page).to have_content(programme_type.title)
    expect(page).to have_link(programme_type.description.to_s)
    expect(programme_type.activity_types.count).to be > 0
    programme_type.activity_types.each do |activity_type|
      expect(page).to have_content(activity_type.name)
    end
  end

  it 'allows a school user to start a programme for their school' do
    click_on programme_type.title
    click_on 'Start this programme'
    expect(page).to have_content(programme_type.title)
    programme_type.activity_types.each do |activity_type|
      expect(page).to have_content(activity_type.name)
    end

    expect(page.all('.activities .completed').size).to eq(1)
    expect(page).to have_content("Points: 25")
    expect(page).to have_content("Points: 25")

  end

  it 'does not allows a school user from a different school to start a programme for that school' do
    click_on 'Schools'
    click_on other_school_name
    expect(page).to_not have_content 'Start programme'
  end
end

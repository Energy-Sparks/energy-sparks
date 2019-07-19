require 'rails_helper'

describe 'programme', type: :system do

  let(:school_name)       { 'Active school'}
  let(:other_school_name) { 'Bash Street' }
  let!(:school)           { create_active_school(name: school_name) }
  let!(:other_school)     { create_active_school(name: other_school_name) }
  let!(:user)             { create(:user, role: 'school_user', school: school) }
  let!(:programme_type)   { create(:programme_type_with_activity_types) }

  let!(:inactive_programme_type) { create(:programme_type, active: false) }
  let!(:activity)  { create(:activity, school: school, activity_type: programme_type.activity_types.first ) }

  before do
    sign_in(user)
    visit root_path
  end

  it 'hides inactive programme types' do
    expect(page).to have_content(programme_type.title)
    expect(page).to_not have_content(inactive_programme_type.title)
  end

  it 'allows the user see details of a programme' do
    click_on programme_type.title
    expect(page).to have_content(programme_type.title)
    expect(page).to have_content(programme_type.description)
    expect(programme_type.activity_types.count).to be > 0
    programme_type.activity_types.each do |activity_type|
      expect(page).to have_content(activity_type.name)
    end
  end

  it 'allows a school user to start a programme for their school' do
    click_on programme_type.title
    click_on 'Start this programme'
    expect(page).to have_content("#{programme_type.title} for #{school_name}")
    programme_type.activity_types.each do |activity_type|
      expect(page).to have_content(activity_type.name)
    end

    expect(page).to have_content("#{programme_type.activity_types.first.name} (Completed)")
    expect(page).to_not have_content("#{programme_type.activity_types.second.name} (Completed)")
    expect(page).to_not have_content("#{programme_type.activity_types.third.name} (Completed)")

    click_on 'School page'
    expect(page).to have_content("Started")
  end

  it 'does not allows a school user from a different school to start a programme for that school' do
    click_on 'Schools'
    click_on other_school_name
    expect(page).to_not have_content 'Start programme'
  end
end

require 'rails_helper'

describe 'adding a new activity' do

  let(:school_name) { 'Active school'}
  let(:activity_type_name) { 'Exciting activity' }
  let(:other_activity_type_name) { 'Exciting activity (please specify)' }
  let(:activity_description) { 'What we did' }
  let(:custom_title) { 'Custom title' }
  let!(:school) { create_active_school(name: school_name)}
  let!(:admin)  { create(:staff, school: school)}
  let!(:activity_type) { create(:activity_type, name: activity_type_name, description: "It's An #{activity_type_name}") }
  let!(:other_activity_type) { create(:activity_type, name: other_activity_type_name, description: nil, custom: true) }

  before(:each) do
    sign_in(admin)
  end

  it 'allows an activity to be created without title' do
    visit activity_type_path(activity_type)
    click_on 'Record this activity'

    expect(find_field(:activity_happened_on).value).to eq Date.today.strftime("%d/%m/%Y")
    click_on 'Save activity'
    expect(page.has_content?('Activity was successfully created.')).to be true
    expect(page.has_content?(activity_type_name)).to be true
    expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
  end

  it 'allows an activity to be created with custom title' do
    visit activity_type_path(other_activity_type)
    click_on 'Record this activity'
    fill_in :activity_title, with: custom_title
    fill_in_trix with: activity_description

    click_on 'Save activity'
    expect(page.has_content?('Activity was successfully created.')).to be true
    expect(page.has_content?(activity_description)).to be true
    expect(page.has_content?(other_activity_type_name)).to be false
    expect(page.has_content?(custom_title)).to be true
    expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
  end

  it 'allows activity to be recorded from individual page, and shows previously completed activities' do
    visit activity_type_path(activity_type)
    click_on 'Record this activity'
    click_on 'Save activity'
    expect(page).to have_content("Activity was successfully created")

    visit activity_type_path(activity_type)
    expect(page).to have_content("Activity previously completed on")

    visit activity_category_path(activity_type.activity_category)
    expect(page).to have_content("Activity previously completed")
    expect(page).to have_content("once")
  end

end

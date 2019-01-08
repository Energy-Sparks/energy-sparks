require 'rails_helper'

describe 'adding a new activity' do

  let(:school_name) { 'Active school'}
  let(:activity_type_name) { 'Exciting activity' }
  let(:activity_description) { 'What we did' }
  let!(:school) { create_active_school(name: school_name)}
  let!(:admin)  { create(:user, role: 'school_user', school: school)}
  let!(:activity_type) { create(:activity_type, name: activity_type_name, description: "It's An #{activity_type_name}") }

  before(:each) do
    sign_in(admin)
    visit school_path(school)
    click_on('Choose an activity')
    click_on('Record your activity')
  end

  it 'allows an activity to be created', js: true do
  #  fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
    expect(page.has_content?(activity_type_name))
    select(activity_type_name, from: 'Activity type')
    fill_in :activity_title, with: 'The title'
    editor = find('trix-editor')
    editor.click.set(activity_description)
    click_on 'Save activity'
    expect(page.has_content?('Activity was successfully created.')).to be true
    expect(page.has_content?(activity_description)).to be true
    expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true

    activity = Activity.first
    expect(activity.title).to eq 'The title'
    expect(activity.description).to eq "<div>#{activity_description}</div>"
    expect(activity.happened_on).to eq Date.today

    expect(Activity.count).to be 1
  end

  it 'defaults activity date to current date' do
    expect(find_field(:activity_happened_on).value).to eq Date.today.strftime("%d/%m/%Y")
  end

  it 'has an activity type to select' do
    expect(page.has_content?(activity_type_name))
  end

end

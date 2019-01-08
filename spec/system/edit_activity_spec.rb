require 'rails_helper'

describe 'editing an activity' do

  let(:school_name) { 'Active school'}
  let(:activity_type_name) { 'Exciting activity' }
  let(:activity_description) { 'What we did' }
  let(:new_activity_description) { 'What we did - or did we?' }
  let!(:school) { create_active_school(name: school_name)}
  let!(:admin)  { create(:user, role: 'school_user', school: school)}
  let!(:activity_type) { create(:activity_type, name: activity_type_name, description: "It's An #{activity_type_name}") }
  let!(:activity) { create(:activity, school: school, activity_type: activity_type, title: activity_type_name, description: activity_description, happened_on: Date.yesterday)}

  before(:each) do
    sign_in(admin)
    visit school_path(school)
    click_on('View activities')
    click_on(activity_type.name)
    click_on('Edit')
  end

  it 'allows an activity to be created', js: true do
    expect(page.has_content?('Update your activity'))

    fill_in :activity_title, with: 'The title'
    editor = find('trix-editor')
    editor.click.set(new_activity_description)
    fill_in :activity_happened_on, with: Date.today.strftime("%d/%m/%Y")
    click_on 'Save activity'
    expect(page.has_content?('Activity was successfully updated.')).to be true
    expect(page.has_content?(new_activity_description)).to be true
    expect(page.has_content?(Date.today.strftime("%A, %d %B %Y"))).to be true
  end

  it 'defaults activity date to correct date' do
    expect(find_field(:activity_happened_on).value).to eq Date.yesterday.strftime("%d/%m/%Y")
  end

  it 'has an activity type to select' do
    expect(page.has_content?(activity_type_name))
  end

end

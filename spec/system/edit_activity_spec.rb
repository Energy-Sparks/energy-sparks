require 'rails_helper'

describe 'editing an activity' do
  let(:school_name) { 'Active school'}
  let(:activity_type_name) { 'Exciting activity' }
  let(:activity_description) { 'What we did' }
  let(:new_activity_description) { 'What we did - or did we?' }
  let(:custom_title) { 'Custom title' }
  let!(:school) { create_active_school(name: school_name)}
  let!(:admin)  { create(:staff, school: school)}
  let!(:activity_type) { create(:activity_type, name: activity_type_name, description: "It's An #{activity_type_name}") }
  let!(:activity) { create(:activity, school: school, activity_type: activity_type, title: activity_type_name, description: activity_description, happened_on: Date.yesterday)}

  before do
    sign_in(admin)
    visit school_path(school)
    click_on('All activities')
    click_on('Edit')
  end

  it 'allows an activity to be updated' do
    expect(page.has_content?('Update your activity'))
    expect(find_field(:activity_happened_on).value).to eq Date.yesterday.strftime('%d/%m/%Y')

    fill_in :activity_happened_on, with: Time.zone.today.strftime('%d/%m/%Y')
    click_on 'Update activity'
    expect(page.has_content?('Activity was successfully updated.')).to be true
    expect(page.has_content?(Time.zone.today.strftime('%A, %d %B %Y'))).to be true
  end

  it 'allows an activity to be updated with custom title' do
    activity_type.update!(custom: true)
    refresh
    expect(page.has_content?('Update your activity'))
    fill_in :activity_title, with: custom_title
    fill_in_trix with: new_activity_description

    click_on 'Update activity'
    expect(page.has_content?('Activity was successfully updated.')).to be true
    expect(page.has_content?(new_activity_description)).to be true
    expect(page.has_content?(custom_title)).to be true
  end
end

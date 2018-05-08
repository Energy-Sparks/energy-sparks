require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:admin)  { create(:user, role: 'admin')}
  let!(:activity_category) { create(:activity_category)}
  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
  let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }

  it 'can not access it unless logged in' do
    visit new_activity_type_path
    expect(page.has_content?("Sign in")).to be true
  end

  describe 'when logged in' do
    before(:each) do
      sign_in(admin)
      visit new_activity_type_path
      expect(ActivityType.count).to be 0
    end

    it 'can add a new activity for KS1' do
      fill_in('Name', with: 'New activity')
      first('input#activity_type_description', visible: false).set("the description")
      fill_in('Score', with: 20)
      fill_in('Badge name', with: 'Badddddger')

      check('KS1')

      click_on('Create Activity type')

      activity_type = ActivityType.first

      expect(activity_type.key_stage_list).to     include('KS1')
      expect(activity_type.key_stage_list).to_not include('KS2')
      expect(activity_type.key_stage_list).to_not include('KS3')

      expect(page.has_content?("Activity type was successfully created.")).to be true
      expect(ActivityType.count).to be 1
    end

    it 'can edit a new activity and add KS2 and KS3' do
      activity_type = create(:activity_type, activity_category: activity_category)
      visit edit_activity_type_path(activity_type)
      expect(page.has_content?(activity_type.name)).to be true

      check('KS2')
      check('KS3')

      click_on('Update Activity type')

      activity_type.reload

      expect(activity_type.key_stage_list).to_not include('KS1')
      expect(activity_type.key_stage_list).to     include('KS2')
      expect(activity_type.key_stage_list).to     include('KS3')

      expect(page.has_content?("Activity type was successfully updated.")).to be true
      expect(ActivityType.count).to be 1
    end
  end
end

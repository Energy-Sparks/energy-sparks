require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:admin)  { create(:user, role: 'admin')}
  let!(:activity_category) { create(:activity_category)}

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

    it 'can add a new activity' do
      fill_in('Name', with: 'New activity')
      first('input#activity_type_description', visible: false).set("the description")
      fill_in('Score', with: 20)
      fill_in('Badge name', with: 'Badddddger')
      click_on('Create Activity type')

      expect(page.has_content?("Activity type was successfully created.")).to be true
      expect(ActivityType.count).to be 1
    end
  end
end

require 'rails_helper'

RSpec.describe 'Activity categories', :scoreboards, type: :system do

  let!(:admin)                  { create(:admin) }
  let!(:activity_category)      { create(:activity_category) }

  describe 'when logged in as an admin' do
    before(:each) do
      sign_in(admin)
      visit root_path
      click_on 'Admin'
    end

    it 'I can view and edit the activity categories' do
      click_on 'Activity Categories'
      new_description = 'Now then'
      new_name = "Alias the jester"
      expect(page).to have_content(activity_category.name)
      expect(page).to have_content(activity_category.description)
      click_on 'Edit'
      fill_in 'Description', with: new_description
      fill_in 'Name', with: ''
      click_on 'Update Activity category'
      expect(page).to have_content("can't be blank")
      fill_in 'Name', with: new_name

      click_on 'Update Activity category'

      expect(page).to have_content('Activity Categories')
      expect(page).to have_content(new_name)
      expect(page).to have_content(new_description)
    end

    it 'I can create a new activity category' do
      click_on 'Activity Categories'
      new_name = "Alias the jester"
      new_description = 'Now then'
      click_on 'New activity category'
      fill_in 'Description', with: new_description
      expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(0)
      expect(page).to have_content("can't be blank")
      fill_in 'Name', with: new_name
       expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(1)
      expect(page).to have_content('Activity Categories')
      expect(page).to have_content(activity_category.name)
      expect(page).to have_content(new_description)
    end
  end

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_activity_categories_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end
end

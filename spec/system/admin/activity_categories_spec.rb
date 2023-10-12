require 'rails_helper'

RSpec.describe 'Activity categories', :scoreboards, type: :system do
  let!(:admin)                  { create(:admin) }
  let!(:activity_category)      { create(:activity_category) }

  describe 'when logged in as an admin' do
    before do
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
      fill_in :activity_category_description_en, with: new_description
      fill_in :activity_category_name_en, with: ''
      click_on 'Update Activity category'
      expect(page).to have_content("can't be blank")
      fill_in :activity_category_name_en, with: new_name
      attach_file(:activity_category_image_en, Rails.root + "spec/fixtures/images/placeholder.png")

      click_on 'Update Activity category'

      expect(page).to have_content('Activity Categories')
      expect(page).to have_content(new_name)
      expect(page).to have_content(new_description)
      expect(ActivityCategory.last.image_en.filename).to eq('placeholder.png')
    end

    it 'I can create a new activity category' do
      click_on 'Activity Categories'
      new_name = "Alias the jester"
      new_description = 'Now then'
      click_on 'New activity category'
      fill_in :activity_category_description_en, with: new_description
      check 'Featured'
      check 'Pupil'
      check 'Live data'
      expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(0)
      expect(page).to have_content("can't be blank")
      fill_in :activity_category_name_en, with: new_name
      attach_file(:activity_category_image_en, Rails.root + "spec/fixtures/images/placeholder.png")
      expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(1)
      expect(page).to have_content('Activity Categories')
      expect(page).to have_content(activity_category.name)
      expect(page).to have_content(new_description)

      new_activity_category = ActivityCategory.last
      expect(new_activity_category.featured).to be_truthy
      expect(new_activity_category.pupil).to be_truthy
      expect(new_activity_category.live_data).to be_truthy
      expect(new_activity_category.image_en.filename).to eq('placeholder.png')
    end

    it 'rejects duplicate name' do
      create(:activity_category, name: 'Wibble')
      click_on 'Activity Categories'
      click_on 'New activity category'
      fill_in :activity_category_name_en, with: "Wibble"
      expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(0)
      expect(page).to have_content("has already been taken")
      fill_in :activity_category_name_en, with: "Wibble2"
      expect { click_on 'Create Activity category' }.to change { ActivityCategory.count }.by(1)
    end
  end

  describe 'when not logged in' do
    it 'does not authorise viewing' do
      visit admin_activity_categories_path
      expect(page).to have_content('You need to sign in or sign up before continuing.')
    end
  end
end

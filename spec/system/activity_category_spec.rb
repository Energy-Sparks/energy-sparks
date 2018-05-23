require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:admin)  { create(:user, role: 'admin')}

  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
  let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }

  let!(:unlikely_school) { create(:school, key_stages: [ks1_tag, ks3_tag])}
  let!(:unlikely_school_user) { create(:user, school: unlikely_school)}

  let!(:activity_category_1) { create(:activity_category, name: 'cat1')}
  let!(:activity_type_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1_tag, ks2_tag])}
  let!(:activity_type_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3_tag])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_2) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3_tag])}


  describe 'filters are set depending on user and if logged in or not' do
    before(:each) do
      visit activity_categories_path
    end

    it 'defaults to all if not signed in' do
      visit activity_categories_path
      expect(page).to have_checked_field('KS1')
      expect(page).to have_checked_field('KS2')
      expect(page).to have_checked_field('KS3') # or have_unchecked_field
      uncheck('KS2')
      uncheck('KS3')
      click_on('Filter Activity Types')
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3')
    end

    it 'defaults to all if signed in as a non-school user' do
      sign_in(admin)
      visit activity_categories_path
      expect(page).to have_checked_field('KS1')
      expect(page).to have_checked_field('KS2')
      expect(page).to have_checked_field('KS3') # or have_unchecked_field
      uncheck('KS2')
      uncheck('KS3')
      click_on('Filter Activity Types')
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3')
    end

    it 'defaults to all if signed in as a non-school user' do
      sign_in(unlikely_school_user)
      visit activity_categories_path
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_checked_field('KS3') # or have_unchecked_field
      uncheck('KS3')
      click_on('Filter Activity Types')
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3')
    end
  end

  describe 'activities can be filtered by tag' do
    before(:each) do
      visit activity_categories_path
    end

    it 'by defaults shows cat 1 activity types', js: true do
      expect(page.has_content?(activity_type_1.name)).to be true
      expect(page.has_content?(activity_type_3.name)).to be true
      expect(page.has_content?(activity_type_2.name)).to_not be true
    end

    it 'shows cat 2 activity types if selected', js: true do
      click_on('cat2')
      assert_text(activity_type_2.name)
      expect(page.has_content?(activity_type_1.name)).to_not be true
      expect(page.has_content?(activity_type_2.name)).to be true
    end

    it 'shows cat 2 activity types if selected' do
      expect(page).to have_checked_field('KS1')
      expect(page).to have_checked_field('KS2')
      expect(page).to have_checked_field('KS3') # or have_unchecked_field
      uncheck('KS2')
      uncheck('KS3')
      click_on('Filter Activity Types')
      expect(page).to have_checked_field('KS1')
      expect(page).to have_unchecked_field('KS2')
      expect(page).to have_unchecked_field('KS3') #

      expect(page.has_content?(activity_type_1.name)).to be true
      expect(page.has_content?(activity_type_3.name)).to_not be true
    end
  end
end

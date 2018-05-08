require 'rails_helper'

RSpec.describe "activity type", type: :system, js: true do
  let!(:admin)  { create(:user, role: 'admin')}

  let!(:ks1_tag) { ActsAsTaggableOn::Tag.create(name: 'KS1') }
  let!(:ks2_tag) { ActsAsTaggableOn::Tag.create(name: 'KS2') }
  let!(:ks3_tag) { ActsAsTaggableOn::Tag.create(name: 'KS3') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1')}
  let!(:activity_type_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1_tag, ks2_tag])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_2) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3_tag])}

  describe 'activities can be filtered by tag' do
    before(:each) do
      visit activity_categories_path
    end

    it 'by defaults shows cat 1 activity types' do
      expect(page.has_content?(activity_type_1.name)).to be true
      expect(page.has_content?(activity_type_2.name)).to_not be true
    end

    it 'shows cat 2 activity types if selected' do
      click_on('cat2')
      assert_text(activity_type_2.name)
      expect(page.has_content?(activity_type_1.name)).to_not be true
      expect(page.has_content?(activity_type_2.name)).to be true
    end 
  end
end

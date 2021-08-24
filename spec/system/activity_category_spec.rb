require 'rails_helper'

RSpec.describe "activity type", type: :system do
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1', description: 'save some energy')}
  let!(:activity_type_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1, ks2])}
  let!(:activity_type_2) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_4) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_5) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_6) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}

  context 'as a public user' do
    describe 'activity categories can be viewed' do
      before(:each) do
        visit activity_categories_path
      end

      it 'shows activity categories with at least 5 activities' do
        expect(page.has_content?(activity_category_1.name)).to be true
        expect(page.has_content?(activity_type_1.name)).to be true
        expect(page.has_content?(activity_type_2.name)).to be true
        expect(page.has_content?(activity_type_3.name)).to be true
        expect(page.has_content?(activity_type_4.name)).to be true
        expect(page.has_content?(activity_type_5.name)).to be true

        expect(page.has_content?(activity_category_2.name)).to_not be true
        expect(page.has_content?(activity_type_6.name)).to_not be true
      end

      it 'shows activity category page' do
        click_link 'View all'
        expect(page.has_content?(activity_category_1.name)).to be true
        expect(page.has_content?(activity_category_1.description)).to be true
        expect(page.has_content?(activity_type_1.name)).to be true
        expect(page.has_content?(activity_type_2.name)).to be true
        expect(page.has_content?(activity_type_3.name)).to be true
        expect(page.has_content?(activity_type_4.name)).to be true
        expect(page.has_content?(activity_type_5.name)).to be true
      end
    end
  end
end

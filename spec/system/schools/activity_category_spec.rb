require 'rails_helper'

RSpec.describe 'activity type', type: :system do
  let!(:school) { create(:school) }
  let!(:user)  { create(:staff, school: school) }

  let!(:ks1) { create(:key_stage, name: 'KS1') }
  let!(:ks2) { create(:key_stage, name: 'KS2') }
  let!(:ks3) { create(:key_stage, name: 'KS3') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1', featured: true) }
  let!(:activity_type_1_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1, ks2], school_specific_description: 'school specific descriptive text here') }
  let!(:activity_type_1_2) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3]) }
  let!(:activity_type_1_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3]) }
  let!(:activity_type_1_4) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3]) }

  let!(:activity_category_2) { create(:activity_category, name: 'cat2', featured: true) }
  let!(:activity_type_2_1) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3]) }

  let!(:activity_category_3) { create(:activity_category, name: 'cat3') }
  let!(:activity_type_3_1) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3]) }

  context 'as a school user' do
    describe 'activity types can be listed' do
      before do
        sign_in(user)
        visit activity_categories_path
      end

      it 'shows categories with 4 activity types' do
        expect(page).to have_content(activity_category_1.name)

        expect(page).to have_content(activity_type_1_1.name)
        expect(page).to have_content(activity_type_1_2.name)

        expect(page).not_to have_content(activity_category_2.name)
        expect(page).not_to have_content(activity_type_2_1.name)
      end

      context 'when user has a school' do
        it_behaves_like 'a recommended prompt'
      end

      context 'when user has no school' do
        let(:user) { create(:admin, school: nil) }

        it_behaves_like 'a recommended prompt', displayed: false
      end

      it 'links to category page, activity page and back' do
        click_link 'View all 4 activities'
        expect(page).to have_content(activity_category_1.name)
        expect(page).to have_content(activity_category_1.description)

        click_link activity_type_1_1.name
        expect(page).to have_content(activity_type_1_1.name)
        expect(page).to have_content('school specific descriptive text here')

        click_link "View #{activity_category_1.activity_types.count} related activities"
        expect(page).to have_content(activity_category_1.name)

        click_link 'All activities'
        expect(page).to have_content('Explore energy saving activities')
      end
    end
  end

  describe 'viewing old recommended page' do
    before do
      sign_in(user)
      visit recommended_activity_categories_path
    end

    context 'when user has a school' do
      let(:user) { create(:staff, school: school) }

      it 'redirects to new recommemndations page for school' do
        expect(page).to have_content('Recommended activities and actions')
      end
    end

    context 'when user has no school' do
      let(:user) { create(:admin, school: nil) }

      it 'redirects to the activity categories index' do
        expect(page).to have_content('Explore energy saving activities')
      end
    end
  end
end

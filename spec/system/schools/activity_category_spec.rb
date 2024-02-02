require 'rails_helper'

RSpec.describe 'activity type', type: :system do
  let!(:school) { create(:school) }
  let!(:admin)  { create(:staff, school: school)}

  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1', featured: true)}
  let!(:activity_type_1_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1, ks2], school_specific_description: 'school specific descriptive text here')}
  let!(:activity_type_1_2) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_1_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_1_4) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2', featured: true)}
  let!(:activity_type_2_1) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}

  let!(:activity_category_3) { create(:activity_category, name: 'cat3')}
  let!(:activity_type_3_1) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3])}

  context 'as a school user' do
    describe 'activity types can be listed' do
      before do
        sign_in(admin)
      end

      it 'shows categories with 4 activity types, plus prompt to view recommendations' do
        visit activity_categories_path

        expect(page).to have_content(activity_category_1.name)
        expect(page).to have_content(activity_type_1_1.name)
        expect(page).to have_content(activity_type_1_2.name)

        expect(page).not_to have_content(activity_category_2.name)
        expect(page).not_to have_content(activity_type_2_1.name)

        expect(page).to have_content("View our recommended activities and actions based on your school's programmes and our analysis of your energy data")
      end

      it 'links to category page, activity page and back' do
        visit activity_categories_path

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
end

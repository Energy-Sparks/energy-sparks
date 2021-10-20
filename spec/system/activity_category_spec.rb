require 'rails_helper'

RSpec.describe "activity category", type: :system do
  let!(:ks1) { KeyStage.create(name: 'KS1') }
  let!(:ks2) { KeyStage.create(name: 'KS2') }
  let!(:ks3) { KeyStage.create(name: 'KS3') }

  let!(:activity_category_1) { create(:activity_category, name: 'cat1', description: 'save some energy', featured: true)}
  let!(:activity_type_1_1) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks1, ks2], description: 'public descriptive text here')}
  let!(:activity_type_1_2) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_1_3) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}
  let!(:activity_type_1_4) { create(:activity_type, activity_category: activity_category_1, key_stages: [ks3])}

  let!(:activity_category_2) { create(:activity_category, name: 'cat2')}
  let!(:activity_type_2_1) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}
  let!(:activity_type_2_2) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}
  let!(:activity_type_2_3) { create(:activity_type, activity_category: activity_category_2, key_stages: [ks3])}

  let!(:activity_category_3) { create(:activity_category, name: 'cat3')}
  let!(:activity_type_3_1) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3])}
  let!(:activity_type_3_2) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3])}
  let!(:activity_type_3_3) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3])}
  let!(:activity_type_3_4) { create(:activity_type, activity_category: activity_category_3, key_stages: [ks3])}

  let!(:activity_category_4) { create(:activity_category, name: 'cat4', pupil: true)}
  let!(:activity_type_4_1) { create(:activity_type, activity_category: activity_category_4)}

  let!(:programme_type) { create(:programme_type, title: 'prog1')}

  context 'as a public user' do
    describe 'activity categories can be viewed' do
      before(:each) do
        visit activity_categories_path
      end

      it 'shows featured activity categories with at least 4 activities, plus Pupil activities and Programmes, but not Recommended section' do
        expect(page).to have_content(activity_category_1.name)
        expect(page).not_to have_content(activity_category_2.name)
        expect(page).not_to have_content(activity_category_3.name)
        expect(page).not_to have_content('Recommended')

        expect(page).to have_content('Pupil activities')
        expect(page).to have_content(activity_category_4.name)

        expect(page).to have_content('Programmes')
        expect(page).to have_content(programme_type.title)
      end

      it 'shows 4 activities' do
        expect(page).to have_content(activity_type_1_1.name)
        expect(page).to have_content(activity_type_1_2.name)
        expect(page).to have_content(activity_type_1_3.name)
        expect(page).to have_content(activity_type_1_4.name)

        expect(page).not_to have_content(activity_type_2_1.name)
        expect(page).not_to have_content(activity_type_3_1.name)
      end

      it 'links to category page, activity page and back' do
        click_link 'View all 4 activities'
        expect(page).to have_content(activity_category_1.name)
        expect(page).to have_content(activity_category_1.description)

        click_link activity_type_1_1.name
        expect(page).to have_content(activity_type_1_1.name)
        expect(page).to have_content('public descriptive text here')

        click_link "View #{activity_category_1.activity_types.count} related activities"
        expect(page).to have_content(activity_category_1.name)

        click_link 'All activities'
        expect(page).to have_content('Explore energy saving activities')
      end

      it 'links to programme type page' do
        within '#programme-types' do
          first(".card-img-top").click
        end
        expect(page).to have_content(programme_type.title)
      end
    end
  end
end

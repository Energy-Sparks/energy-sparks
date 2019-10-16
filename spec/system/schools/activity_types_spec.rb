require 'rails_helper'

RSpec.describe "activity type", type: :system do

  let(:school_name)               { 'Active school'}
  let(:activity_type_name)        { 'Exciting activity' }
  let(:other_activity_type_name)  { 'Boring activity' }
  let(:activity_description)      { 'What we did' }
  let(:custom_title)              { 'Custom title' }

  let!(:school)                   { create_active_school(name: school_name)}
  let!(:teacher)                  { create(:staff, school: school)}
  let!(:activity_type)            { create(:activity_type, name: activity_type_name, description: "It's An #{activity_type_name}") }
  let!(:other_activity_type)      { create(:activity_type, name: other_activity_type_name, description: "It's An #{activity_type_name}", activity_category: activity_type.activity_category) }

  context 'as a logged in school user' do
    describe 'I can see the' do
      before(:each) do
        sign_in(teacher)
        visit root_path
        click_on 'Choose another activity'
        click_on 'View the full list of activities'
      end

      it 'activity types' do
        click_on activity_type_name
        expect(page).to have_content(school_name)
        expect(page).to have_content(activity_type.description.to_plain_text)
      end

      it 'completed activities' do
        create(:activity, activity_type: activity_type, activity_category: activity_type.activity_category, school: school)
        expect(school.activities.includes(:activity_type).where(activity_type: activity_type).any?).to be true

        refresh

        click_on activity_type_name
        expect(page).to have_content(school_name)
        expect(page).to have_content(activity_type.description.to_plain_text)
        expect(page).to have_content('Completed at')
      end

    end
  end
end


require 'rails_helper'

describe 'activity type reports', type: :system do
  let(:admin)              { create(:admin) }

  let!(:activity_type)     { create(:activity_type) }
  let!(:school)            { create(:school, :with_school_group) }
  let!(:activity)          { create(:activity, school: school, activity_type: activity_type) }

  before do
    sign_in(admin)
    visit admin_reports_path
  end

  context 'the activity type management report' do
    before do
      click_on 'Activity type management report'
    end

    it 'displays the report' do
      expect(page).to have_content('Activity Type Management Report')
      expect(page).to have_content(activity_type.name)
      expect(page).to have_link(activity_type.name, href: admin_reports_activity_type_path(activity_type))
      expect(page).to have_link('Report', href: admin_reports_activity_type_path(activity_type))
    end
  end

  context 'the activity type report' do
    before do
      visit admin_reports_path
      click_on 'Activity type management report'
    end

    it 'displays the report' do
      click_on activity_type.name

      expect(page).to have_content activity_type.name
      expect(page).to have_content school.name
      expect(page).to have_link(school.name, href: school_url(school, host: 'example.com'))
    end

    context 'when the activity has been recorded multiple times' do
      let!(:activity2) { create(:activity, school: school, activity_type: activity_type) }

      it 'includes a summary' do
        click_on activity_type.name
        expect(page).to have_content('This activity has been recorded multiple times by some schools')
      end
    end
  end
end

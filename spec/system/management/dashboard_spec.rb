require 'rails_helper'

describe 'Management dashboard' do
  let(:school_name)         { 'Theresa Green Infants'}
  let!(:school_group)       { create(:school_group) }

  let!(:regional_calendar)  { create(:regional_calendar) }
  let!(:calendar)           { create(:school_calendar, based_on: regional_calendar) }

  let!(:school)             { create(:school, :with_feed_areas, calendar: calendar, name: school_name, school_group: school_group) }

  describe 'when not logged in' do
    it 'prompts for login' do
      visit management_school_path(school)
      expect(page).to have_content("Sign in to Energy Sparks")
    end
  end

  describe 'when logged in' do
    let(:staff)   { create(:staff, school: school) }

    before(:each) do
      sign_in(staff)
      visit management_school_path(school)
    end

    it 'redirects to school dashboard' do
      expect(current_path).to eq(school_path(school))
    end
  end
end

require 'rails_helper'

describe 'timelines', :timelines, type: :system do
  let!(:calendar) { create(:calendar, :based_on_regional) }
  let!(:school_group) { create(:school_group) }
  let!(:school) { create(:school, calendar:, school_group:) }
  let!(:observation) { create(:observation, :activity, school:) }

  describe 'school timeline' do
    before do
      visit school_timeline_path(school)
    end

    it 'shows observations' do
      expect(page).to have_content(observation.description)
    end
  end
end

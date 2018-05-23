require 'rails_helper'

RSpec.describe "calendar view", type: :system, js: true do
  include_context 'calendar data'

  describe 'does lots of good calendar work' do
    let!(:admin)  { create(:user, role: 'admin') }

    it 'shows the calendar' do
      sign_in(admin)
      visit calendar_path(calendar)
      expect(page.has_content?(area_and_calendar_title)).to be true
      expect(page.has_content?('January')).to be true
    end
  end
end

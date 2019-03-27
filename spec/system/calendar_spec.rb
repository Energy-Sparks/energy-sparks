require 'rails_helper'

RSpec.describe "calendar view", type: :system do
  include_context 'calendar data'

  describe 'does lots of good calendar work', js: true do
    let!(:admin)  { create(:user, role: 'admin') }

    it 'shows the calendar' do
      sign_in(admin)
      visit calendar_path(calendar)
      expect(page.has_content?(area_and_calendar_title)).to be true
      expect(page.has_content?('January')).to be true
    end
  end

  describe 'a school admin can only do things with their calendar' do

    let!(:school)           { create_active_school }
    let!(:school_admin)     { create(:user, role: :school_admin, school: school) }
    let!(:school_calendar) do

      cal = CalendarFactory.new(calendar, 'New calendar').create
      cal.schools << school
      cal
    end

    it 'allows them to add an event to their calendar' do
      calendar_event_count = CalendarEvent.count

      sign_in(school_admin)
      visit school_path(school)

      click_on('Calendar')
      click_on('Add Event to calendar')
      fill_in 'Title', with: 'Calendar event'
      first('input#calendar_event_start_date', visible: false).set('16/08/2018')
      first('input#calendar_event_end_date', visible: false).set('17/08/2018')

      click_on 'Create Calendar event'
      expect(CalendarEvent.count).to eq calendar_event_count + 1
    end

    it "but not to someone else's calendar" do
      sign_in(school_admin)
      visit calendar_path(calendar)

      expect(page).to have_content("You are not authorized")
    end
  end
end

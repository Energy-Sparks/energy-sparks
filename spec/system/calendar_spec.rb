require 'rails_helper'

RSpec.describe "calendar view", type: :system do
  include_context 'calendar data'

  describe 'does lots of good calendar work', js: true do
    let!(:admin)  { create(:admin) }

    it 'shows the calendar' do
      create(:academic_year, calendar: calendar, start_date: Date.parse("01/01/#{Date.today.year}"))

      sign_in(admin)
      visit calendar_path(calendar)
      expect(page.has_content?(calendar.title)).to be true
      expect(page.has_content?('January')).to be true

      find('div.month-container:nth-child(1) > table:nth-child(1) > tbody:nth-child(2) > tr:nth-child(2) > td:nth-child(3) > div:nth-child(1)').click
      expect(page).to have_content('New Calendar Event')

      expect(page).to have_content('Event Type')
      select 'Holiday - Holiday', from: 'calendar_event_calendar_event_type_id'

      fill_in(:calendar_event_title, with: 'Exciting day off')
      expect { click_on('Save') }.to change { calendar.calendar_events.count }.by(1)
      find('div.month-container:nth-child(1) > table:nth-child(1) > tbody:nth-child(2) > tr:nth-child(2) > td:nth-child(3) > div:nth-child(1)').click
      expect(page).to have_content('Edit Calendar Event')
      expect(page).to have_content('Delete')
      click_on('Delete')

      expect { click_on('Ok') }.to change { calendar.calendar_events.count }.by(-1)
    end
  end

  describe 'a school admin can only do things with their calendar' do

    let!(:school)           { create_active_school }
    let!(:school_admin)     { create(:school_admin, school: school) }
    let!(:school_calendar) do

      cal = CalendarFactory.new(existing_calendar: calendar, title: 'New calendar', calendar_type: :school).create
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

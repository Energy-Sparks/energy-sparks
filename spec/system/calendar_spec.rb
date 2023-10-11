require 'rails_helper'

RSpec.describe 'calendar view', type: :system do
  include_context 'calendar data'

  context 'as an admin' do
    let!(:admin) { create(:admin) }

    before do
      create(:academic_year, calendar: calendar, start_date: Date.parse("01/01/#{Date.today.year}"))
      sign_in(admin)
      visit calendar_path(calendar)
    end

    it 'current events are rendered with just the events data table' do
      visit current_events_calendar_path(calendar)
      expect(page).to have_content('Type')
      expect(page).to have_content('Start Date')
      expect(page).to have_content('End Date')
      expect(page).not_to have_content(calendar.title)
    end

    describe 'using the calendar view', js: true do
      xit 'shows the calendar, allows an event to be added and deleted - flickering' do
        click_on('Calendar view')
        # wait for view to display
        expect(page).to have_css('.calendar-legend')

        # check title, etc
        expect(page.has_content?(calendar.title)).to be true
        expect(page.has_content?('January')).to be true

        # add an event on this day
        fifteenth_jan = find('.calendar .day', text: '15', match: :first)
        fifteenth_jan.click

        expect(page).to have_content('New Calendar Event')

        select 'Holiday - Holiday', from: 'calendar_event_calendar_event_type_id'

        # potential race condition here
        expect { click_on('Save') }.to change { calendar.calendar_events.count }.by(1)

        # switch tab
        click_on('Calendar view')

        # Wait until ajax call is back
        assert_selector('td[style*="background-color"]')

        fifteenth_jan.click
        expect(page).to have_content('Edit Calendar Event')
        click_on('Save')

        # switch tab
        click_on('Calendar view')

        # Wait until ajax call is back
        assert_selector('td[style*="background-color"]')

        fifteenth_jan.click
        expect(page).to have_content('Delete')

        expect { click_on('Delete') }.to change { calendar.calendar_events.count }.by(-1)
      end
    end
  end

  describe 'a school admin can' do
    let!(:school)           { create_active_school }
    let!(:school_admin)     { create(:school_admin, school: school) }
    let!(:school_calendar) do
      cal = CalendarFactory.new(existing_calendar: calendar, title: 'New calendar', calendar_type: :school).create
      cal.schools << school
      cal
    end

    it 'add an event to their calendar' do
      calendar_event_count = CalendarEvent.count

      sign_in(school_admin)
      visit school_path(school)

      click_on('School calendar')
      click_on('Add new event', match: :first)
      first('input#calendar_event_start_date', visible: false).set('16/08/2018')
      first('input#calendar_event_end_date', visible: false).set('17/08/2018')

      click_on 'Create Calendar event'
      expect(CalendarEvent.count).to eq calendar_event_count + 1
    end

    it "but not to someone else's calendar" do
      sign_in(school_admin)
      visit calendar_path(calendar)

      expect(page).to have_content('You are not authorized')
    end
  end
end

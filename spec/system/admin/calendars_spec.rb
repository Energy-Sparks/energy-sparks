require 'rails_helper'

RSpec.describe 'calendars', :calendar do
  include ActiveJob::TestHelper

  let!(:admin) { create(:admin) }

  let(:events) do
    <<~CSV
      Term,Start Date,End Date
      2015-2016 Term 1,01/09/2015,23/10/2015
    CSV
  end

  let!(:england_and_wales_calendar) { create :national_calendar, title: 'England and Wales' }
  let!(:bank_holiday)               { create :bank_holiday, calendar: england_and_wales_calendar, start_date: '2012-04-06', end_date: '2012-04-06' }

  before do
    travel_to Time.zone.local(2023, 8, 24)
    create_all_calendar_events
    AcademicYearFactory.new(england_and_wales_calendar).create(start_year: 2014, end_year: 2016)
  end

  after do
    travel_back
  end

  describe 'when logged in' do
    before do
      sign_in(admin)
      visit root_path
    end

    it 'create a regional calendar with the events for the calendar added via a text field' do
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Calendars'
      click_on 'New regional calendar'
      click_on 'Create Calendar'
      expect(page).to have_content("can't be blank")

      fill_in 'Title', with: 'Trumptonshire'
      select 'England and Wales', from: 'Based on'
      fill_in 'Terms CSV', with: events
      click_on 'Create Calendar'
      expect(page).to have_content('Calendar created')
      expect(page).not_to have_content("can't be blank")

      calendar = Calendar.regional.first!
      expect(calendar.terms.count).to eq(1)

      expect(calendar.based_on).to eq(england_and_wales_calendar)

      click_on 'Delete'
      expect(page).to have_content('Calendar was successfully deleted.')
      expect(Calendar.regional.count).to eq 0
    end

    it 'allows calendar to be edited' do
      regional_calendar_1 = create(:regional_calendar, title: 'Old regional calendar')
      regional_calendar_2 = create(:regional_calendar, title: 'New regional calendar')
      calendar = create(:calendar, based_on: regional_calendar_1)
      click_on 'Manage'
      click_on 'Admin'
      click_on 'Calendars'
      within '.school-calendars' do
        click_on 'Edit'
      end

      fill_in 'Title', with: 'Updated..'
      select 'New regional calendar', from: 'Based on'
      click_on 'Update Calendar'
      expect(page).to have_content('Calendar was successfully updated.')

      calendar.reload
      expect(calendar.title).to eq('Updated..')
      expect(calendar.based_on).to eq(regional_calendar_2)
    end

    it 'allows calendar to be resynced to dependents' do
      regional_calendar = create(:regional_calendar, title: 'Regional calendar')
      parent_event = create(:calendar_event_holiday, calendar: regional_calendar, description: 'Regional calendar event', start_date: '2021-01-01')

      calendar = CalendarFactory.new(existing_calendar: regional_calendar, title: 'child calendar', calendar_type: :school).create
      expect(calendar.calendar_events.count).to eq(1)
      expect(calendar.calendar_events.last.description).to eq('Regional calendar event')
      expect(calendar.calendar_events.last.start_date).to eq(Date.parse('2021-01-01'))

      parent_event.update(description: 'new description')
      parent_event.update(start_date: '2021-06-06')

      click_on 'Manage'
      click_on 'Admin'
      click_on 'Calendars'
      within '.regional-calendars' do
        click_on 'Show'
      end

      click_on 'Update dependent schools'
      expect(page).to have_content('Update job has been submitted. An email will be sent')

      perform_enqueued_jobs
      mail = ActionMailer::Base.deliveries.last.to_s
      expect(mail).to include("Resync completed for #{regional_calendar.title}")
      expect(mail).to include('Events deleted')
      expect(mail).to include('Events created')
      calendar.reload
      expect(calendar.calendar_events.count).to eq(1)
      expect(calendar.calendar_events.last.description).to eq('new description')
      expect(calendar.calendar_events.last.start_date).to eq(Date.parse('2021-06-06'))
    end

    it 'shows status of calendar events and resets parent to nil after edit' do
      regional_calendar = create(:regional_calendar, title: 'Regional calendar')
      parent_event = create(:calendar_event_holiday, calendar: regional_calendar, description: 'Regional calendar event')
      calendar = CalendarFactory.new(existing_calendar: regional_calendar, title: 'child calendar', calendar_type: :school).create

      expect(calendar.calendar_events.first.based_on).to eq(parent_event)

      visit calendar_path(calendar)
      expect(page).to have_content('inherited')
      click_on 'Edit'
      fill_in 'Start Date', with: parent_event.start_date - 1.day
      click_on 'Update Calendar event'

      expect(page).to have_content('Event was successfully updated.')
      expect(page).not_to have_content('inherited')

      expect(calendar.calendar_events.first.reload.based_on).to be_nil
    end
  end
end

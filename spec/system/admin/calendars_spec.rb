require 'rails_helper'

RSpec.describe 'calendars', :calendar, type: :system do

  let!(:admin) { create(:admin) }

  let(:events) do
    <<~CSV
      Term,Start Date,End Date
      2015-2016 Term 1,01/09/2015,23/10/2015
    CSV
  end

  let!(:england_and_wales_calendar) { create :national_calendar, title: 'England and Wales'  }
  let!(:bank_holiday)               { create :bank_holiday, calendar: england_and_wales_calendar, title: 'Good Friday', start_date: "2012-04-06", end_date: "2012-04-06" }

  before do
    create_all_calendar_events
    AcademicYearFactory.new(england_and_wales_calendar).create(start_year: 2014, end_year: 2016)
  end

  describe 'when logged in' do
    before(:each) do
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
      expect(page).to have_content("Calendar created")
      expect(page).to_not have_content("can't be blank")

      calendar = Calendar.regional.first!
      expect(calendar.terms.count).to eq(1)

      expect(calendar.based_on).to eq(england_and_wales_calendar)
    end
  end
end

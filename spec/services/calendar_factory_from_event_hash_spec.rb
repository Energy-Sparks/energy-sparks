require 'rails_helper'

describe CalendarFactoryFromEventHash do
  include CalendarData

  describe 'creates calendars from hashes' do
    let!(:area) { Area.create(title: 'this area') }
    let(:bank_holiday_date) { '01-08-2018'}
    let(:bank_holiday_title) { 'SuperBH' }

    let!(:bank_holiday) { BankHoliday.create(area: area, holiday_date: bank_holiday_date, title: bank_holiday_title)}
    let!(:academic_years) { AcademicYearFactory.new(1990, 2023).create }
    let(:calendar) { CalendarFactoryFromEventHash.new(CalendarData::EXAMPLE_CALENDAR_HASH, area) }

    it 'creates full calendar with academic years' do 
      expect(Calendar.count).to be 0
      calendar = CalendarFactoryFromEventHash.new(CalendarData::EXAMPLE_CALENDAR_HASH, area).create
      expect(Calendar.count).to be 1
      expect(calendar.terms.count).to be 24
      expect(calendar.holidays.count).to be 1
      expect(calendar.inset_days.count).to be 1     
      expect(calendar.calendar_events.count).to be 26
    end
    # let(:title) { 'new calendar' }
    # it "creates a new calendar" do
    #   expect {
    #     Calendar.create_calendar_from_default(name)
    #   }.to change(Calendar, :count).by(1)
    # end
    # it "sets the name from the parameter" do
    #   calendar = Calendar.create_calendar_from_default(name)
    #   expect(calendar.name).to eq name
    # end
    # it "duplicates the terms from the default calendar (no school id)" do
    #   default_calendar = FactoryBot.create :calendar, default: true
    #   FactoryBot.create :term, calendar_id: default_calendar.id
    #   FactoryBot.create :term, calendar_id: default_calendar.id
    #   calendar = Calendar.create_calendar_from_default(name)
    #   expect(calendar.terms.count).to eq 2
    # end
  end
end

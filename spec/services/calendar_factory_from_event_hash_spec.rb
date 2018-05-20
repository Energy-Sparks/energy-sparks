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

      # 1 Bank Holiday and 23 holidays between tterms
      expect(calendar.holidays.count).to be 1 + (calendar.terms.count - 1)
      expect(calendar.inset_days.count).to be 1     
      expect(calendar.calendar_events.count).to be 49
    end
  end
end

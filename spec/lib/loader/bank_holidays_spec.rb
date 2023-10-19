require 'rails_helper'
require 'loader/bank_holidays'

module Loader
  describe BankHolidays do
    let!(:sample_file)        { 'spec/fixtures/test-bank-holidays.json' }
    let!(:national_calendar)  { create :calendar, calendar_type: :national, title: 'test-area' }
    let!(:bank_holiday)       { create :calendar_event_type, :bank_holiday }
    let!(:academic_year)      { create :academic_year, start_date: Date.parse('01/01/2016'), end_date: Date.parse('01/12/2016'), calendar: national_calendar }

    it 'parses the json file and create a bank holiday for the top level calendar' do
       BankHolidays.load!(sample_file)
       expect(national_calendar.bank_holidays.count).to be 1
       expect(national_calendar.bank_holidays.first.start_date).to eq Date.parse("2016-08-16")
    end

    it 'does not cascade to child calendars' do
      child_calendar = create :calendar, based_on_id: national_calendar.id, calendar_type: :regional
      BankHolidays.load!(sample_file)
      expect(child_calendar.bank_holidays.count).to be 0
    end
  end
end

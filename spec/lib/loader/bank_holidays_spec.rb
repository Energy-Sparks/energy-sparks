
require 'rails_helper'
require 'loader/bank_holidays.rb'

module Loader

  describe BankHolidays do

    let!(:sample_file)        { 'spec/fixtures/test-bank-holidays.json' }
    let!(:calendar_area)      { create :calendar_area, title: 'test-area'}
    let!(:top_level_calendar) { create :calendar, template: true, calendar_area: calendar_area }
    let!(:bank_holiday)       { create :calendar_event_type, :bank_holiday }
    let!(:academic_year)      { create :academic_year, start_date: Date.parse('01/01/2016'), end_date: Date.parse('01/12/2016'), calendar_area: calendar_area }

    it 'should parse the json file and create a bank holiday for the top level calendar' do
       BankHolidays.load!(sample_file)
       expect(top_level_calendar.bank_holidays.count).to be 1
       expect(top_level_calendar.bank_holidays.first.start_date).to eq Date.parse("2016-08-16")
    end

    it 'should cascade to child calendars' do
      child_calendar = create :calendar, calendar_area: calendar_area, based_on_id: top_level_calendar.id
      BankHolidays.load!(sample_file)
      expect(child_calendar.bank_holidays.count).to be 1
      expect(child_calendar.bank_holidays.first.start_date).to eq Date.parse("2016-08-16")
    end
  end
end


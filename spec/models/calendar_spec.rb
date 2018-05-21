require 'rails_helper'

describe Calendar do
  include CalendarData

  describe '.create_calendar_from_default' do
    let!(:area) { create(:area, title: 'AREA') }
    let!(:academic_years) { AcademicYearFactory.new(2017, 1019).create }
    let!(:bank_holiday) { create :bank_holiday, title: 'Good Friday', holiday_date: "2012-04-06" }  
    let!(:calendar_events) { CalendarEventTypeFactory.create }

    let(:autumn_terms) { 
      [{ term: "2017-18 Term 1", start_date: "2017-09-04", end_date: "2017-10-20" },
      { term: "2017-18 Term 2", start_date: "2017-10-30", end_date: "2017-12-15" }]
    }
    let!(:calendar)       { CalendarFactoryFromEventHash.new(autumn_terms, area).create }

    it 'creates a calendar with academic years' do 
      expect(calendar.calendar_events.count).to be 4
      expect(calendar.holidays.count).to be 1
      expect(calendar.bank_holidays.count).to be 1
    end

    it 'creates a holiday between the terms' do 
      expect(calendar.calendar_events.count).to be 4
      expect(calendar.holidays.first.start_date).to eq calendar.terms.first.end_date + 1.day
      expect(calendar.holidays.first.end_date).to eq calendar.terms.second.start_date - 1.day
    end
  end
end

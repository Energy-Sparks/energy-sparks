require 'rails_helper'

describe CalendarFactoryFromEventHash do
  include_context 'calendar data'

  describe 'creates calendars from hashes' do
    it 'creates full calendar with academic years' do
      example_calendar_hash = [
        {:term=>"2015-16 Term 1", :start_date=>"2015-09-02", :end_date=>"2015-10-21"},
        {:term=>"2015-16 Term 2", :start_date=>"2015-11-02", :end_date=>"2015-12-18"},
        {:term=>"2015-16 Term 3", :start_date=>"2016-01-04", :end_date=>"2016-02-12"},
        {:term=>"2015-16 Term 4", :start_date=>"2016-02-22", :end_date=>"2016-04-01"},
        {:term=>"2015-16 Term 5", :start_date=>"2016-04-18", :end_date=>"2016-05-27"}
      ]
      expect(Calendar.count).to be 1

      new_area = CalendarArea.create(title: 'this new area', parent_area: area)
      calendar = CalendarFactoryFromEventHash.new(example_calendar_hash, new_area).create

      expect(Calendar.count).to be 2
      expect(calendar.terms.count).to be 5

      # 1 Bank Holiday, 5 terms and 4 holidays
      expect(calendar.holidays.count).to be (4)
      expect(calendar.inset_days.count).to be 0
      expect(calendar.calendar_events.count).to be 10
    end
  end
end

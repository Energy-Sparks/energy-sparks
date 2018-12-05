require 'rails_helper'

describe CalendarFactoryFromEventHash do
  include_context 'calendar data'

  describe 'creates calendars from hashes' do
    it 'creates full calendar with academic years' do
      example_calendar_hash = [{:term=>"2015-16 Term 1", :start_date=>"2015-09-02", :end_date=>"2015-10-21"}, {:term=>"2015-16 Term 2", :start_date=>"2015-11-02", :end_date=>"2015-12-18"}, {:term=>"2015-16 Term 3", :start_date=>"2016-01-04", :end_date=>"2016-02-12"}, {:term=>"2015-16 Term 4", :start_date=>"2016-02-22", :end_date=>"2016-04-01"}, {:term=>"2015-16 Term 5", :start_date=>"2016-04-18", :end_date=>"2016-05-27"}, {:term=>"2015-16 Term 6", :start_date=>"2016-06-06", :end_date=>"2016-07-19"}, {:term=>"2016-17 Term 1", :start_date=>"2016-09-01", :end_date=>"2016-10-21"}, {:term=>"2016-17 Term 2", :start_date=>"2016-10-31", :end_date=>"2016-12-16"}, {:term=>"2016-17 Term 3", :start_date=>"2017-01-03", :end_date=>"2017-02-10"}, {:term=>"2016-17 Term 4", :start_date=>"2017-02-20", :end_date=>"2017-04-07"}, {:term=>"2016-17 Term 5", :start_date=>"2017-04-24", :end_date=>"2017-05-26"}, {:term=>"2016-17 Term 6", :start_date=>"2017-06-05", :end_date=>"2017-07-21"}, {:term=>"2017-18 Term 1", :start_date=>"2017-09-04", :end_date=>"2017-10-20"}, {:term=>"2017-18 Term 2", :start_date=>"2017-10-30", :end_date=>"2017-12-15"}, {:term=>"2017-18 Term 3", :start_date=>"2018-01-02", :end_date=>"2018-02-09"}, {:term=>"2017-18 Term 4", :start_date=>"2018-02-19", :end_date=>"2018-03-23"}, {:term=>"2017-18 Term 5", :start_date=>"2018-04-09", :end_date=>"2018-05-25"}, {:term=>"2017-18 Term 6", :start_date=>"2018-06-04", :end_date=>"2018-07-24"}, {:term=>"2018-19 Term 1", :start_date=>"2018-09-03", :end_date=>"2018-10-26"}, {:term=>"2018-19 Term 2", :start_date=>"2018-11-05", :end_date=>"2018-12-21"}, {:term=>"2018-19 Term 3", :start_date=>"2019-01-07", :end_date=>"2019-02-15"}, {:term=>"2018-19 Term 4", :start_date=>"2019-02-25", :end_date=>"2019-04-05"}, {:term=>"2018-19 Term 5", :start_date=>"2019-04-23", :end_date=>"2019-05-24"}, {:term=>"2018-19 Term 6", :start_date=>"2019-06-03", :end_date=>"2019-07-23"}].freeze
      expect(Calendar.count).to be 1

      area = CalendarArea.create(title: 'this new area')
      calendar = CalendarFactoryFromEventHash.new(example_calendar_hash, area).create

      expect(Calendar.count).to be 2
      expect(calendar.terms.count).to be 24

      # 1 Bank Holiday and 23 holidays between tterms
      expect(calendar.holidays.count).to be (calendar.terms.count - 1)
      expect(calendar.inset_days.count).to be 0
      expect(calendar.calendar_events.count).to be 48
    end
  end
end

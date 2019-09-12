require 'rails_helper'

describe CalendarFactoryFromEventHash do
  include_context 'calendar data'

  describe 'creates calendars from hashes' do
    it 'creates full calendar with academic years' do
      example_calendar_hash = [
        {:term=>"2018-16 Term 1", :start_date=>"2018-09-02", :end_date=>"2018-10-21"},
        {:term=>"2018-16 Term 2", :start_date=>"2018-11-02", :end_date=>"2018-12-18"},
        {:term=>"2018-16 Term 3", :start_date=>"2019-01-04", :end_date=>"2019-02-12"},
        {:term=>"2018-16 Term 4", :start_date=>"2019-02-22", :end_date=>"2019-04-01"},
        {:term=>"2018-16 Term 5", :start_date=>"2019-04-18", :end_date=>"2019-05-27"}
      ]

      parent_template_calendar = create(:regional_calendar, :with_academic_years)
      create(:bank_holiday, calendar: parent_template_calendar)
      new_calendar_title = 'New calendar'


      expect { CalendarFactoryFromEventHash.new(title: new_calendar_title, event_hash: example_calendar_hash, template_calendar: parent_template_calendar).create }.to change { Calendar.count }.by(1)

      calendar = Calendar.last
      # 1 Bank Holiday, 5 terms and 4 holidays
      expect(calendar.holidays.count).to be (4)
      expect(calendar.inset_days.count).to be 0
      expect(calendar.calendar_events.count).to be 10
      expect(calendar.title).to eq new_calendar_title
    end
  end
end

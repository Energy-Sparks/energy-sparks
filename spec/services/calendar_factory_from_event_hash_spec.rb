require 'rails_helper'

describe CalendarFactoryFromEventHash do
  include_context 'calendar data'

  describe 'creates calendars from hashes' do
    it 'creates full calendar with academic years' do
      expect(Calendar.count).to be 1

      area = CalendarArea.create(title: 'this new area')
      calendar = CalendarFactoryFromEventHash.new(EXAMPLE_CALENDAR_HASH, area).create

      expect(Calendar.count).to be 2
      expect(calendar.terms.count).to be 24

      # 1 Bank Holiday and 23 holidays between tterms
      expect(calendar.holidays.count).to be (calendar.terms.count - 1)
      expect(calendar.inset_days.count).to be 0
      expect(calendar.calendar_events.count).to be 48
    end
  end
end

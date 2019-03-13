require 'rails_helper'

describe ScheduleDataManagerService do
  include_context 'calendar data'

  describe '#holidays' do
    let!(:school)           { create_active_school }
    let!(:school_calendar) do
      cal = CalendarFactory.new(calendar, 'New calendar').create
      cal.schools << school
      cal
    end
    let(:date_version_of_holiday_date_from_calendar) { Date.parse(random_before_holiday_start_date) }

    it 'assigns school date periods for the analytics code' do
      results = ScheduleDataManagerService.new(school).holidays
      school_date_period = results.find_holiday(date_version_of_holiday_date_from_calendar)
      expect(school_date_period.start_date).to eq date_version_of_holiday_date_from_calendar
      expect(school_date_period.type).to eq :holiday
    end
  end
end

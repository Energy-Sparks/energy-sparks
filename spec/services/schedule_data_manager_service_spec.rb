require 'rails_helper'

describe ScheduleDataManagerService do
  include_context 'calendar data'

  describe '#holidays' do
    let!(:school)                                    { create(:school, calendar: calendar) }
    let(:date_version_of_holiday_date_from_calendar) { Date.parse(random_before_holiday_start_date) }

    it 'assigns school date periods for the analytics code' do
      results = ScheduleDataManagerService.new(school).holidays
      school_date_period = results.find_holiday(date_version_of_holiday_date_from_calendar)
      expect(school_date_period.start_date).to eq date_version_of_holiday_date_from_calendar
      expect(school_date_period.type).to_not be_nil
    end
  end
end

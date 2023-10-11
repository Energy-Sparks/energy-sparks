require 'rails_helper'

describe CalendarTermFactory do
  describe 'creates terms from hashes' do
    it 'creates full calendar with academic years' do
      create_all_calendar_events

      example_calendar_hash = [
        { term: '2018-16 Term 1', start_date: '2018-09-02', end_date: '2018-10-21' },
        { term: '2018-16 Term 2', start_date: '2018-11-02', end_date: '2018-12-18' },
        { term: '2018-16 Term 3', start_date: '2019-01-04', end_date: '2019-02-12' },
        { term: '2018-16 Term 4', start_date: '2019-02-22', end_date: '2019-04-01' },
        { term: '2018-16 Term 5', start_date: '2019-04-18', end_date: '2019-05-27' }
      ]

      holiday_count = 4
      term_count = example_calendar_hash.size

      calendar = create(:regional_calendar, :with_academic_years)
      create(:academic_year, start_date: Date.parse('2018-09-01'), end_date: Date.parse('2019-08-30'), calendar: calendar)

      expect { CalendarTermFactory.new(calendar, example_calendar_hash).create_terms }.to change(CalendarEvent, :count).by(holiday_count + term_count)

      calendar.reload

      # 1 Bank Holiday, 5 terms and 4 holidays
      expect(calendar.holidays.count).to be 4
      expect(calendar.inset_days.count).to be 0
      expect(calendar.terms.count).to be 5
    end
  end

  it 'does not create something if it cannot find type' do
    example_calendar_hash = [{ toddle: '2018-16 Term 1', start_date: '2018-09-02', end_date: '2018-10-21' }]

    calendar = create(:regional_calendar, :with_academic_years)
    expect { CalendarTermFactory.new(calendar, example_calendar_hash).create_terms }.to raise_error(ArgumentError)
  end
end

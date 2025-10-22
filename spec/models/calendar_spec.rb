require 'rails_helper'

describe Calendar do
  include_context 'calendar data'

  describe 'valid calendar event types' do
    it 'is bank holidays only, for national' do
      national_calendar = create(:national_calendar)
      expect(national_calendar.valid_calendar_event_types).to match_array(CalendarEventType.bank_holiday)
    end

    it 'is all apart from bank holidays for regional' do
      regional_calendar = create(:regional_calendar)
      expect(regional_calendar.valid_calendar_event_types).not_to include(CalendarEventType.bank_holiday)
    end

    it 'is all apart from bank holidays for school' do
      school_calendar = create(:school_calendar)
      expect(school_calendar.valid_calendar_event_types).not_to include(CalendarEventType.bank_holiday)
    end
  end

  describe 'does lots of good calendar work' do
    it 'creates a calendar with academic years' do
      expect(calendar.calendar_events.count).to be 6
      expect(calendar.holidays.count).to be 3
      expect(calendar.bank_holidays.count).to be 1
    end

    it 'creates a holiday between the terms' do
      expect(calendar.calendar_events.count).to be 6
      does_holiday_fit_space_between_terms?(calendar)
    end

    def does_holiday_fit_space_between_terms?(calendar)
      expect(calendar.holidays.first.start_date).to eq calendar.terms.first.end_date + 1.day
      expect(calendar.holidays.first.end_date).to eq calendar.terms.second.start_date - 1.day
    end
  end

  describe 'it knows when alert triggers are coming up' do
    it 'knows when the next holiday is' do
      today = Date.parse(autumn_term_half_term_holiday_start) - 1.week
      expect(calendar.next_holiday(today: today).start_date.to_fs(:db)).to eq autumn_term_half_term_holiday_start

      today = Date.parse(random_before_holiday_start_date) - 1.week
      expect(calendar.next_holiday(today: today).start_date).to eq random_before_holiday.start_date

      today = Date.parse(random_after_holiday_start_date) - 1.week
      expect(calendar.next_holiday(today: today).start_date).to eq random_after_holiday.start_date
    end

    it 'knows there is a holiday approaching' do
      holiday_start_date = Date.parse(autumn_terms[0][:end_date]) + 1.day

      today = holiday_start_date - 2.weeks
      expect(calendar.holiday_approaching?(today: today)).to be false

      today = holiday_start_date - 1.week
      expect(calendar.holiday_approaching?(today: today)).to be true

      today = holiday_start_date - 3.days
      expect(calendar.holiday_approaching?(today: today)).to be true

      today = holiday_start_date - 2.days
      expect(calendar.holiday_approaching?(today: today)).to be true
    end

    it 'knows there is a holiday approaching' do
      create(:calendar)
      expect(calendar.holiday_approaching?).to be false
    end
  end

  describe '.default_national' do
    subject(:default_national) { Calendar.default_national }

    context 'when England and Wales exists' do
      before do
        create(:calendar, calendar_type: :national, title: 'England and Wales')
      end

      it { expect(default_national.title).to eq('England and Wales') }
    end

    context 'when there is no default' do
      it { expect(default_national).to be_nil }
    end
  end
end

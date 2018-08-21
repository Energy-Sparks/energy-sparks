require 'rails_helper'

describe Calendar do
  include_context 'calendar data'

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

    it 'still has a holiday which fits, after term time is shortened at the end' do
      new_term_end = Date.parse('18-10-2017')
      calendar.terms.first.update(end_date: new_term_end)
      expect(calendar.holidays.first.start_date).to eq new_term_end + 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a holiday which fits, after term time is lengthened at the end' do
      new_term_end = Date.parse('23-10-2017')
      calendar.terms.first.update(end_date: new_term_end)
      expect(calendar.holidays.first.start_date).to eq new_term_end + 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a holiday which fits, after term time is shortened at the beginning' do
      new_term_start = Date.parse('01-11-2017')
      calendar.terms.last.update(start_date: new_term_start)
      expect(calendar.holidays.first.end_date).to eq new_term_start - 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a holiday which fits, after term time is lengthend at the beginning' do
      new_term_start = Date.parse('25-10-2017')
      calendar.terms.last.update(start_date: new_term_start)
      expect(calendar.holidays.first.end_date).to eq new_term_start - 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    #    holiday: 21/10/2017 - 29/10/2017
    it 'still has a term which fits, after holiday time is shortened at the beginning' do
      new_holiday_start = Date.parse('23-10-2017')
      calendar.holidays.first.update(start_date: new_holiday_start)
      expect(calendar.terms.first.end_date).to eq new_holiday_start - 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a term which fits, after holiday time is lengthend at the beginning' do
      new_holiday_start = Date.parse('15-10-2017')
      calendar.terms.last.update(start_date: new_holiday_start)
      expect(calendar.holidays.first.end_date).to eq new_holiday_start - 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a term which fits, after holiday time is shortened at the end' do
      new_holiday_end = Date.parse('26-10-2017')
      calendar.terms.first.update(end_date: new_holiday_end)
      expect(calendar.holidays.first.start_date).to eq new_holiday_end + 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    it 'still has a term which fits, after holiday time is lengthened at the end' do
      new_holiday_end = Date.parse('30-10-2017')
      calendar.terms.first.update(end_date: new_holiday_end)
      expect(calendar.holidays.first.start_date).to eq new_holiday_end + 1.day
      does_holiday_fit_space_between_terms?(calendar)
    end

    def does_holiday_fit_space_between_terms?(calendar)
      expect(calendar.holidays.first.start_date).to eq calendar.terms.first.end_date + 1.day
      expect(calendar.holidays.first.end_date).to eq calendar.terms.second.start_date - 1.day
    end
  end

  describe 'it knows when alert triggers are coming up' do

    it 'knows when the next holiday is' do
      Timecop.freeze(Date.parse(autumn_term_half_term_holiday_start) - 1.week) do
        expect(calendar.next_holiday.start_date.to_s(:db)).to eq autumn_term_half_term_holiday_start
      end

      Timecop.freeze(Date.parse(random_before_holiday_start_date) - 1.week) do
        expect(calendar.next_holiday.start_date).to eq random_before_holiday.start_date
      end

      Timecop.freeze(Date.parse(random_after_holiday_start_date) - 1.week) do
        expect(calendar.next_holiday.start_date).to eq random_after_holiday.start_date
      end
    end

    it 'knows there is a holiday approaching' do
      holiday_start_date = Date.parse(autumn_terms[0][:end_date]) + 1.day

      Timecop.freeze(holiday_start_date - 1.week) do
        expect(calendar.holiday_approaching?).to be false
      end

      Timecop.freeze(holiday_start_date - 3.days) do
        expect(calendar.holiday_approaching?).to be true
      end

      Timecop.freeze(holiday_start_date - 2.days) do
        expect(calendar.holiday_approaching?).to be false
      end
    end


#   let(:autumn_term_half_term_holiday_start) { "2017-10-21" }
#   let(:autumn_term_half_term_end)           { "2017-10-20" }

#   let(:autumn_terms) {
#     [{ term: "2017-18 Term 1", start_date: "2017-09-04", end_date: autumn_term_half_term_end },
#      { term: "2017-18 Term 2", start_date: "2017-10-30", end_date: "2017-12-15" }]
#   }
#   let!(:calendar) { CalendarFactoryFromEventHash.new(autumn_terms, area).create }

#   let(:random_before_holiday_start_date) { '01/01/2017' }
#   let(:random_after_holiday_start_date)  { '16/12/2017' }

#   let!(:random_before_holiday) {
#     CalendarEvent.create(
#       title: 'random holiday',
#       calendar: calendar,
#       calendar_event_type: CalendarEventType.holiday.first,
#       start_date: random_before_holiday_start_date,
#       end_date: '01/02/2017')}
#   let!(:random_after_holiday) {
#     CalendarEvent.create(
#       title: 'random holiday 2',
#       calendar: calendar,
#       calendar_event_type: CalendarEventType.holiday.first,
#       start_date: '16/12/2017',
#       end_date: '20/12/2017')}
# end









  # let(:autumn_terms) {
  #   [{ term: "2017-18 Term 1", start_date: "2017-09-04", end_date: "2017-10-20" },
  #    { term: "2017-18 Term 2", start_date: "2017-10-30", end_date: "2017-12-15" }]
  # }

  end
end

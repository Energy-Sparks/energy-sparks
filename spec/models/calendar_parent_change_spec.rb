require 'rails_helper'

describe 'ParentCalendarChange' do
  include_context 'calendar data'

  let(:template_calendar) { calendar }

  describe 'a parent calendar with a child' do
    let(:child_calendar)  { CalendarFactory.new(existing_calendar: calendar, title: 'New calendar').create }

    it 'has a relationship' do
      expect(child_calendar.based_on).to eq template_calendar
      expect(template_calendar.calendars.count).to eq 1
      expect(template_calendar.calendars.first).to eq child_calendar
    end

    it 'events have a relationship' do
      expect(child_calendar.calendar_events.count).to eq template_calendar.calendar_events.count
      expect(child_calendar.calendar_events.first.based_on).to eq template_calendar.calendar_events.first
      expect(child_calendar.calendar_events.last.based_on).to eq template_calendar.calendar_events.last
    end

    it 'if a child has a new term, the parent is not updated' do
      expect(child_calendar.terms.count).to be 2
      expect(template_calendar.terms.count).to be 2
      calendar_event = create(:term, calendar: child_calendar)
      expect(child_calendar.terms.count).to be 3
      expect(template_calendar.terms.count).to be 2
    end

    it 'if a parent has a new term, the child is updated' do
      expect(child_calendar.terms.count).to be 2
      expect(child_calendar.holidays.count).to be 3
      expect(template_calendar.terms.count).to be 2
      calendar_event = create(:term, calendar: template_calendar)
      expect(template_calendar.terms.count).to be 3
      expect(child_calendar.holidays.count).to be 3

      expect(child_calendar.terms.count).to be 3
      child_calendar.terms.each do |term|
        expect(term.calendar).to eq child_calendar
      end
    end
  end

  describe 'a parent calendar with children' do
    let(:child_name_1)      { 'New child calendar 1' }
    let(:child_name_2)      { 'New child calendar 2' }
    let(:child_calendar_1)  { CalendarFactory.new(existing_calendar: calendar, title: child_name_1).create }
    let(:child_calendar_2)  { CalendarFactory.new(existing_calendar: calendar, title: child_name_2).create }

    it 'has a relationship' do
      expect(child_calendar_1.based_on).to eq template_calendar
      expect(child_calendar_2.based_on).to eq template_calendar

      expect(template_calendar.calendars.count).to eq 2
      expect(template_calendar.calendars.first).to eq child_calendar_1
      expect(template_calendar.calendars.second).to eq child_calendar_2
    end

    it 'if a child has a new term, the parent is not updated' do
      expect(child_calendar_1.terms.count).to be 2
      expect(child_calendar_2.terms.count).to be 2
      expect(template_calendar.terms.count).to be 2
      calendar_event = create(:term, calendar: child_calendar_2)
      expect(child_calendar_1.terms.count).to be 2
      expect(child_calendar_2.terms.count).to be 3
      expect(template_calendar.terms.count).to be 2
    end

    it 'if a parent has a new term, the children are updated' do
      create_calendar_event_type = :term
      initial_amount = 2
      calendar_event_type = CalendarEventType.term.first
      expect(template_calendar.terms.count).to be initial_amount
      expect(child_calendar_1.terms.count).to be initial_amount
      check_and_create_calendar_event_type_for_parent(calendar_event_type, create_calendar_event_type, initial_amount)
    end

    it 'if a parent has a new holiday, the children are updated' do
      create_calendar_event_type = :holiday
      initial_amount = 3
      calendar_event_type = CalendarEventType.holiday.first
      expect(template_calendar.holidays.count).to be initial_amount
      expect(child_calendar_1.holidays.count).to be initial_amount
      check_and_create_calendar_event_type_for_parent(calendar_event_type, create_calendar_event_type, initial_amount, 4, 4)
    end

    def check_and_create_calendar_event_type_for_parent(calendar_event_type, create_calendar_event_type = :term, initial_amount = 2, child_calendar_1_expected_after = initial_amount + 1, child_calendar_2_expected_after = initial_amount + 1)
      calendar_event_types = create_calendar_event_type.to_s.pluralize.to_sym

      expect(child_calendar_2.send(calendar_event_types).count).to be initial_amount

      calendar_event = create(create_calendar_event_type, calendar: template_calendar, calendar_event_type: calendar_event_type)
      expect(template_calendar.send(calendar_event_types).count).to be initial_amount + 1
      expect(child_calendar_1.send(calendar_event_types).count).to be child_calendar_1_expected_after
      expect(child_calendar_2.send(calendar_event_types).count).to be child_calendar_2_expected_after

      child_calendar_1.send(calendar_event_types).each do |term|
        expect(term.calendar).to eq child_calendar_1
      end
      child_calendar_2.send(calendar_event_types).each do |term|
        expect(term.calendar).to eq child_calendar_2
      end
    end

    it 'if a parent has a new term, but the child has a conflicting one for the same dates, then that child is skipped' do
      new_term_start_date = 1.year.from_now
      new_term_end_date = new_term_start_date + 8.weeks

      new_child_term_start_date = new_term_start_date
      new_child_term_end_date = new_term_end_date

      run_and_check_with_term_dates_for_parent_and_child(new_term_start_date, new_term_end_date, new_child_term_start_date, new_child_term_end_date)
    end

    it 'if a parent has a new term, but the child has a conflicting one with an earlier start, then that child is skipped' do
      new_term_start_date = 1.year.from_now
      new_term_end_date = new_term_start_date + 8.weeks

      new_child_term_start_date = new_term_start_date - 4.days
      new_child_term_end_date = new_term_end_date - 4.days

      run_and_check_with_term_dates_for_parent_and_child(new_term_start_date, new_term_end_date, new_child_term_start_date, new_child_term_end_date)
    end

    it 'if a parent has a new term, but the child has a conflicting one with a later start, then that child is skipped' do
      new_term_start_date = 1.year.from_now
      new_term_end_date = new_term_start_date + 8.weeks

      new_child_term_start_date = new_term_start_date + 4.days
      new_child_term_end_date = new_term_end_date + 4.days

      run_and_check_with_term_dates_for_parent_and_child(new_term_start_date, new_term_end_date, new_child_term_start_date, new_child_term_end_date)
    end

    it 'if a parent has a new term, but the child has a conflicting one with which overlaps at both ends, then that child is skipped' do
      new_term_start_date = 1.year.from_now
      new_term_end_date = new_term_start_date + 8.weeks

      new_child_term_start_date = new_term_start_date - 4.days
      new_child_term_end_date = new_term_end_date + 4.days

      run_and_check_with_term_dates_for_parent_and_child(new_term_start_date, new_term_end_date, new_child_term_start_date, new_child_term_end_date)
    end

    def run_and_check_with_term_dates_for_parent_and_child(new_term_start_date, new_term_end_date, new_child_term_start_date, new_child_term_end_date)
      create_calendar_event_type = :term
      calendar_event_types = create_calendar_event_type.to_s.pluralize.to_sym
      initial_amount = 2
      calendar_event_type = CalendarEventType.term.first

      expect(template_calendar.send(calendar_event_types).count).to be initial_amount
      expect(child_calendar_1.send(calendar_event_types).count).to be initial_amount

      calendar_event = create(create_calendar_event_type, calendar: child_calendar_1, calendar_event_type: calendar_event_type, start_date: new_child_term_start_date, end_date: new_child_term_end_date)

      expect(child_calendar_1.send(calendar_event_types).count).to be initial_amount + 1
      expect(child_calendar_2.send(calendar_event_types).count).to be initial_amount

      calendar_event = create(create_calendar_event_type, calendar: template_calendar, calendar_event_type: calendar_event_type, start_date: new_term_start_date, end_date: new_term_end_date)

      expect(template_calendar.send(calendar_event_types).count).to be initial_amount + 1
      expect(child_calendar_1.send(calendar_event_types).count).to be initial_amount + 1
      expect(child_calendar_2.send(calendar_event_types).count).to be initial_amount + 1
    end
  end
end

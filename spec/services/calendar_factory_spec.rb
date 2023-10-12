require 'rails_helper'

describe CalendarFactory do
  include_context 'calendar data'

  let(:template_calendar) { calendar }

  describe 'a parent calendar with a child' do
    let(:child_calendar) { CalendarFactory.new(existing_calendar: calendar, title: 'New calendar').create }

    it 'has a relationship' do
      expect(child_calendar.based_on).to eq template_calendar
      expect(template_calendar.calendars.count).to eq 1
      expect(template_calendar.calendars.first).to eq child_calendar
    end

    it 'events reference the parent event' do
      expect(child_calendar.calendar_events.count).to eq template_calendar.calendar_events.count
      expect(child_calendar.calendar_events.first.based_on).to eq template_calendar.calendar_events.first
      expect(child_calendar.calendar_events.last.based_on).to eq template_calendar.calendar_events.last
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
  end
end

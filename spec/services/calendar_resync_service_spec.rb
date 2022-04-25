require 'rails_helper'

describe CalendarResyncService do

  let(:parent) { create(:regional_calendar) }
  let!(:calendar) { create(:school_calendar, based_on: parent) }

  let!(:parent_event) { create(:holiday, calendar: parent, description: 'parent event') }

  context 'when child has no events' do
    it 'creates new events based on parent' do
      expect(calendar.calendar_events.count).to eq(0)
      CalendarResyncService.new(parent).resync
      expect(calendar.calendar_events.count).to eq(1)
      expect(calendar.calendar_events.first.description).to eq('parent event')
      expect(calendar.calendar_events.first.based_on).to eq(parent_event)
    end
  end

  context 'when child has event based on parent' do
    let!(:calendar_event) { create(:holiday, calendar: calendar, description: 'calendar event', based_on: parent_event) }
    it 'updates child events' do
      expect(calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(parent).resync
      expect(calendar.calendar_events.count).to eq(1)
      expect(calendar.calendar_events.first.description).to eq('parent event')
      expect(calendar.calendar_events.first.based_on).to eq(parent_event)
    end
  end

  context 'when child has conflicting event' do
    let!(:parent_event) { create(:term, calendar: parent, description: 'parent event', start_date: '2021-01-01', end_date: '2021-02-01') }
    let!(:calendar_event) { create(:term, calendar: calendar, description: 'calendar event', start_date: '2021-01-01', end_date: '2021-02-01') }

    it 'skips child with conflicting events' do
      expect(calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(parent).resync
      expect(calendar.calendar_events.count).to eq(1)
      expect(calendar.calendar_events.first.description).to eq('calendar event')
      expect(calendar.calendar_events.first.based_on).to be_nil
    end

    it 'still updates other child where no conflicting events' do
      other_calendar = create(:school_calendar, based_on: parent)
      other_calendar_event = create(:term, calendar: other_calendar, description: 'calendar event', start_date: '2019-01-01', end_date: '2019-02-01')
      expect(other_calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(parent).resync
      expect(other_calendar.calendar_events.count).to eq(2)
      expect(other_calendar.calendar_events.first.description).to eq('calendar event')
      expect(other_calendar.calendar_events.first.based_on).to be_nil
      expect(other_calendar.calendar_events.last.description).to eq('parent event')
      expect(other_calendar.calendar_events.last.based_on).to eq(parent_event)
    end
  end
end

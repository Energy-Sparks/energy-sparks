require 'rails_helper'

describe CalendarResyncService do

  let(:parent) { create(:regional_calendar) }
  let!(:calendar_1) { create(:school_calendar, based_on: parent) }
  let!(:calendar_2) { create(:school_calendar, based_on: parent) }

  let!(:parent_event) { create(:holiday, calendar: parent, description: 'parent event') }

  context 'when child has no events' do
    it 'creates new events based on parent' do
      expect(calendar_1.calendar_events.count).to eq(0)
      expect(calendar_2.calendar_events.count).to eq(0)
      CalendarResyncService.new(parent).resync
      expect(calendar_1.calendar_events.first.description).to eq('parent event')
      expect(calendar_2.calendar_events.first.description).to eq('parent event')
    end
  end

  context 'when child has event based on parent' do
    let!(:calendar_event_1) { create(:holiday, calendar: calendar_1, description: 'calendar event 1', based_on: parent_event, start_date: parent_event.start_date, end_date: parent_event.end_date) }
    let!(:calendar_event_2) { create(:holiday, calendar: calendar_2, description: 'calendar event 2', based_on: parent_event, start_date: parent_event.start_date, end_date: parent_event.end_date) }
    it 'updates child events' do
      expect(calendar_1.calendar_events.count).to eq(1)
      expect(calendar_2.calendar_events.count).to eq(1)
      CalendarResyncService.new(parent).resync
      expect(calendar_1.calendar_events.first.description).to eq('parent event')
      expect(calendar_2.calendar_events.first.description).to eq('parent event')
    end
  end
end

require 'rails_helper'

describe CalendarResyncService do

  let(:parent) { create(:calendar, :with_academic_years) }
  let(:calendar_1) { create(:calendar, :with_academic_years, based_on: parent) }
  let(:calendar_2) { create(:calendar, :with_academic_years, based_on: parent) }

  let!(:parent_event) { create(:holiday, calendar: parent, description: 'parent event') }

  # context 'when child has no events' do
  #   it 'creates new events based on parent' do
  #     CalendarResyncService.new(parent).resync
  #     expect(calendar.calendar_events.count).to eq(parent.calendar_events.count)
  #     expect(calendar.calendar_events.last.description).to eq('parent event')
  #     expect(calendar.calendar_events.last).not_to eq(parent.calendar_events.last)
  #   end
  # end

  context 'when child has event based on parent' do
    let!(:calendar_event_1) { create(:holiday, calendar: calendar_1, description: 'calendar event 1', based_on: parent_event) }
    let!(:calendar_event_2) { create(:holiday, calendar: calendar_2, description: 'calendar event 2', based_on: parent_event) }
    it 'updates child events' do
      CalendarResyncService.new(parent).resync
      expect(calendar_event_1.reload.description).to eq('parent event')
      expect(calendar_event_2.reload.description).to eq('parent event')
    end
  end
end

require 'rails_helper'

describe CalendarResetService do

  let(:parent) { create(:calendar, :with_academic_years) }
  let(:calendar) { create(:calendar, :with_academic_years, based_on: parent) }

  let!(:parent_event) { create(:holiday, calendar: parent, description: 'parent event') }
  let!(:calendar_event) { create(:holiday, calendar: calendar, description: 'calendar event') }

  it 'deletes existing events' do
    CalendarResetService.new(calendar).reset
    expect(calendar.calendar_events).not_to include(calendar_event)
  end

  it 'creates new events based on parent' do
    CalendarResetService.new(calendar).reset
    expect(calendar.calendar_events.count).to eq(parent.calendar_events.count)
    expect(calendar.calendar_events.last.description).to eq('parent event')
    expect(calendar.calendar_events.last).not_to eq(parent.calendar_events.last)
  end
end

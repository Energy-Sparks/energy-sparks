require 'rails_helper'

describe CalendarResetService do

  let(:parent_calendar) { create(:calendar, :with_academic_years) }
  let!(:parent_calendar_event) { create(:holiday, calendar: parent_calendar, description: 'parent event') }
  let!(:parent_calendar_inset_day_event) { create(:inset_day, calendar: parent_calendar, description: 'parent inset day event') }

  let(:child_calendar) { create(:calendar, :with_academic_years, based_on: parent_calendar) }
  let!(:child_calendar_event) { create(:holiday, calendar: child_calendar, description: 'child event') }
  let!(:child_calendar_inset_day_event) { create(:inset_day, calendar: child_calendar, description: 'child inset day event') }

  it 'deletes existing term and holiday events but not inset days' do
    CalendarResetService.new(child_calendar).reset
    expect(child_calendar.calendar_events).not_to include(child_calendar_event)
    expect(child_calendar.calendar_events).to include(child_calendar_inset_day_event)
  end

  it 'creates new events based on parent term and holiday but not inset day' do
    CalendarResetService.new(child_calendar).reset
    expect(child_calendar.calendar_events.count).to eq(2)
    expect(child_calendar.calendar_events.map(&:description)).to include('parent event')
    expect(child_calendar.calendar_events.map(&:description)).to include('child inset day event')
  end
end

require 'rails_helper'

describe CalendarResetService do
  let(:parent_calendar) { create(:calendar, :with_academic_years) }
  let!(:parent_calendar_event) do
    create(:calendar_event_holiday, calendar: parent_calendar, description: 'parent event')
  end
  let!(:parent_calendar_bank_holiday_event) do
    create(:bank_holiday, calendar: parent_calendar, description: 'parent bank holiday')
  end
  let!(:parent_calendar_inset_day_event) do
    create(:inset_day, calendar: parent_calendar, description: 'parent inset day event')
  end

  let(:child_calendar) { create(:calendar, :with_academic_years, based_on: parent_calendar) }
  let!(:child_calendar_event) { create(:calendar_event_holiday, calendar: child_calendar, description: 'child event') }
  let!(:child_calendar_bank_holiday_event) do
    create(:bank_holiday, calendar: child_calendar, description: 'child bank holiday')
  end
  let!(:child_calendar_inset_day_event) do
    create(:inset_day, calendar: child_calendar, description: 'child inset day event')
  end

  it 'deletes existing term and holiday events but not inset days' do
    CalendarResetService.new(child_calendar).reset
    expect(child_calendar.calendar_events).not_to include(child_calendar_event)
    expect(child_calendar.calendar_events).not_to include(child_calendar_bank_holiday_event)
    expect(child_calendar.calendar_events).to include(child_calendar_inset_day_event)
  end

  it 'creates new events based on parent term and holiday but not inset day' do
    CalendarResetService.new(child_calendar).reset
    expect(child_calendar.calendar_events.count).to eq(3)
    expect(child_calendar.calendar_events.map(&:description)).to include('parent event')
    expect(child_calendar.calendar_events.map(&:description)).to include('parent bank holiday')
    expect(child_calendar.calendar_events.map(&:description)).not_to include('parent inset day event')
  end

  it 'new events have reference to parent events' do
    CalendarResetService.new(child_calendar).reset
    expect(child_calendar.calendar_events.holidays.first.based_on).to eq(parent_calendar_event)
    expect(child_calendar.calendar_events.bank_holidays.first.based_on).to eq(parent_calendar_bank_holiday_event)
  end
end

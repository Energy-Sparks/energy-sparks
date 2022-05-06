require 'rails_helper'

describe CalendarInitService do

  let(:holiday) { create(:calendar_event_type, :holiday) }
  let(:bank_holiday) { create(:calendar_event_type, :bank_holiday) }
  let(:inset_day) { create(:calendar_event_type, :inset_day_in_school) }

  let(:start_date) { Date.parse('2020-01-01') }
  let(:parent_calendar) { create(:calendar, :with_academic_years, title: 'parent calendar') }
  let!(:parent_calendar_event) { create(:calendar_event, calendar_event_type: holiday, calendar: parent_calendar, description: 'parent event', start_date: start_date, end_date: start_date + 1.month) }
  let!(:parent_calendar_bank_holiday_event) { create(:calendar_event, calendar_event_type: bank_holiday, calendar: parent_calendar, description: 'parent bank holiday') }
  let!(:parent_calendar_inset_day_event) { create(:calendar_event, calendar_event_type: inset_day, calendar: parent_calendar, description: 'parent inset day event') }

  let(:child_calendar) { create(:calendar, :with_academic_years, based_on: parent_calendar, title: 'child calendar') }
  let!(:child_calendar_event) { create(:calendar_event, calendar_event_type: holiday, calendar: child_calendar, description: 'child event', start_date: start_date, end_date: start_date + 1.month) }
  let!(:child_calendar_bank_holiday_event) { create(:calendar_event, calendar_event_type: bank_holiday, calendar: child_calendar, description: 'child bank holiday') }
  let!(:child_calendar_inset_day_event) { create(:calendar_event, calendar_event_type: inset_day, calendar: child_calendar, description: 'child inset day event') }

  it 'sets based on for matching events' do
    CalendarInitService.new(child_calendar).call
    expect(child_calendar_event.reload.based_on).to eq(parent_calendar_event)
    expect(child_calendar_bank_holiday_event.reload.based_on).to eq(parent_calendar_bank_holiday_event)
    expect(child_calendar_inset_day_event.reload.based_on).to eq(parent_calendar_inset_day_event)
  end
end

require 'rails_helper'

describe CalendarResyncService do

  let!(:national_calendar)  { create(:calendar, calendar_type: :national) }
  let!(:regional_calendar)  { create(:calendar, calendar_type: :regional, based_on: national_calendar) }
  let!(:school_calendar)    { create(:calendar, calendar_type: :school, based_on: regional_calendar) }

  let!(:national_calendar_event) { create(:bank_holiday, calendar: national_calendar, description: 'national event', start_date: '2020-01-01', end_date: '2020-01-02') }
  let!(:regional_calendar_event) { create(:holiday, calendar: regional_calendar, description: 'regional event') }

  context 'when child has no events' do
    it 'creates new events based on parent' do
      expect(school_calendar.calendar_events.count).to eq(0)
      CalendarResyncService.new(regional_calendar).resync
      expect(school_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.first.description).to eq('regional event')
      expect(school_calendar.calendar_events.first.based_on).to eq(regional_calendar_event)
    end
  end

  context 'when child calendar has child calendar' do
    it 'only cascades top event down to lowest level' do
      expect(regional_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.count).to eq(0)
      CalendarResyncService.new(national_calendar).resync
      expect(regional_calendar.calendar_events.count).to eq(2)
      expect(school_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.first.description).to eq('national event')
    end
  end

  context 'when restricting earliest event to sync' do
    let(:from_date) { Date.parse('2021-06-06') }
    let(:old_regional_calendar_event) { create(:holiday, calendar: regional_calendar, description: 'old regional event', start_date: '2020-01-01', end_date: '2020-01-01') }

    before :each do
      old_regional_calendar_event.update(updated_at: from_date - 1.day)
    end

    it 'creates new events for recent events only' do
      expect(regional_calendar.calendar_events.count).to eq(2)
      expect(school_calendar.calendar_events.count).to eq(0)
      CalendarResyncService.new(regional_calendar, from_date).resync
      expect(school_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.first.description).to eq('regional event')
      expect(school_calendar.calendar_events.first.based_on).to eq(regional_calendar_event)
    end
  end

  context 'when child has event based on parent' do
    let!(:calendar_event) { create(:holiday, calendar: school_calendar, description: 'calendar event', based_on: regional_calendar_event) }
    it 'updates child events' do
      expect(school_calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(regional_calendar).resync
      expect(school_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.first.description).to eq('regional event')
      expect(school_calendar.calendar_events.first.based_on).to eq(regional_calendar_event)
    end
  end

  context 'when regional event has been deleted' do
    it 'deletes child events' do
      CalendarResyncService.new(regional_calendar).resync
      expect(school_calendar.calendar_events.count).to eq(1)
      regional_calendar.calendar_events.destroy_all
      regional_calendar.reload
      CalendarResyncService.new(regional_calendar).resync
      expect(school_calendar.calendar_events.count).to eq(0)
    end
  end

  context 'when child has conflicting event' do
    let!(:regional_calendar_event) { create(:term, calendar: regional_calendar, description: 'regional event', start_date: '2021-01-01', end_date: '2021-02-01') }
    let!(:school_calendar_event) { create(:term, calendar: school_calendar, description: 'calendar event', start_date: '2021-01-01', end_date: '2021-02-01') }

    it 'skips child with conflicting events' do
      expect(school_calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(regional_calendar).resync
      expect(school_calendar.calendar_events.count).to eq(1)
      expect(school_calendar.calendar_events.first.description).to eq('calendar event')
      expect(school_calendar.calendar_events.first.based_on).to be_nil
    end

    it 'still updates other child where no conflicting events' do
      other_calendar = create(:school_calendar, based_on: regional_calendar)
      other_calendar_event = create(:term, calendar: other_calendar, description: 'other calendar event', start_date: '2019-01-01', end_date: '2019-02-01')
      expect(other_calendar.calendar_events.count).to eq(1)
      CalendarResyncService.new(regional_calendar).resync
      expect(other_calendar.calendar_events.count).to eq(2)
      expect(other_calendar.calendar_events.first.description).to eq('other calendar event')
      expect(other_calendar.calendar_events.first.based_on).to be_nil
      expect(other_calendar.calendar_events.last.description).to eq('regional event')
      expect(other_calendar.calendar_events.last.based_on).to eq(regional_calendar_event)
    end
  end
end

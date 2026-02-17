require 'rails_helper'

describe HolidayFactory do
  subject(:holiday_factory) { described_class.new(calendar) }

  before { create(:calendar_event_type, :holiday) }

  let(:calendar) { create :calendar }

  describe '#create' do
    it 'creates holidays between two events' do
      create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
      create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
      holiday_factory.create
      expect(calendar.calendar_events.holidays.count).to eq(1)
      expect(calendar.calendar_events.holidays.first.start_date).to eq(Date.new(2018, 3, 24))
      expect(calendar.calendar_events.holidays.first.end_date).to eq(Date.new(2018, 4, 19))
    end

    it 'creates holidays between multiple events' do
      create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
      create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
      create(:term, calendar: calendar, start_date: Date.new(2018, 5, 19), end_date: Date.new(2018, 5, 22))
      holiday_factory.create
      expect(calendar.calendar_events.holidays.count).to eq(2)
      expect(calendar.calendar_events.holidays.first.start_date).to eq(Date.new(2018, 3, 24))
      expect(calendar.calendar_events.holidays.first.end_date).to eq(Date.new(2018, 4, 19))
      expect(calendar.calendar_events.holidays.last.start_date).to eq(Date.new(2018, 5, 3))
      expect(calendar.calendar_events.holidays.last.end_date).to eq(Date.new(2018, 5, 18))
    end

    it 'does not create holidays when there is only one term' do
      create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
      holiday_factory.create
      expect(calendar.calendar_events.holidays.count).to eq(0)
    end

    it 'does not create holidays when the terms start and end on consecutive days' do
      create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
      create(:term, calendar: calendar, start_date: Date.new(2018, 3, 24), end_date: Date.new(2018, 5, 2))
      holiday_factory.create
      expect(calendar.calendar_events.holidays.count).to eq(0)
    end
  end

  describe '#process_event_update' do
    describe 'when calendar has a parent' do
      let(:parent_calendar) { create :calendar, calendars: [calendar] }

      describe 'when the event has changed' do
        it 'resets the based_on of the event and any updated neighbours' do
          term_1_parent = create(:term, calendar: parent_calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2_parent = create(:term, calendar: parent_calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_1_parent = create(:calendar_event_holiday, calendar: parent_calendar, start_date: Date.new(2018, 3, 24), end_date: Date.new(2018, 4, 19))
          term_1 = create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23), based_on: term_1_parent)
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2), based_on: term_2_parent)
          holiday_factory.create
          calendar.calendar_events.holidays.first.update(based_on: holiday_1_parent)
          expect(holiday_factory.with_neighbour_updates(term_2, { start_date: Date.new(2018, 4, 25) })).to eq(true)
          expect(term_1.based_on).not_to be_nil
          expect(term_2.based_on).to be_nil
          expect(calendar.calendar_events.holidays.first.based_on).to be_nil
        end
      end
    end

    describe 'when updating a term' do
      describe 'when the start_date has changed' do
        it 'moves a preceding holiday end date forwards' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_2, { start_date: Date.new(2018, 4, 25) })).to eq(true)
          expect(calendar.calendar_events.holidays.first.end_date).to eq(Date.new(2018, 4, 24))
        end

        it 'moves a preceding holiday end date backwards' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_2, { start_date: Date.new(2018, 4, 19) })).to eq(true)
          expect(calendar.calendar_events.holidays.first.end_date).to eq(Date.new(2018, 4, 18))
        end

        it 'deletes a preceding holiday when it is no longer valid' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_2, { start_date: Date.new(2018, 3, 24) })).to eq(true)
          expect(calendar.calendar_events.holidays.count).to eq(0)
        end
      end

      describe 'when the end_date has changed' do
        it 'moves a following holiday start date forwards' do
          term_1 = create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_1, { end_date: Date.new(2018, 3, 24) })).to eq(true)
          expect(calendar.calendar_events.holidays.first.start_date).to eq(Date.new(2018, 3, 25))
        end

        it 'moves a following holiday start date backwards' do
          term_1 = create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_1, { end_date: Date.new(2018, 3, 21) })).to eq(true)
          expect(calendar.calendar_events.holidays.first.start_date).to eq(Date.new(2018, 3, 22))
        end

        it 'deletes a following holiday when it is no longer valid' do
          term_1 = create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(term_1, { end_date: Date.new(2018, 4, 19) })).to eq(true)
          expect(calendar.calendar_events.holidays.count).to eq(0)
        end
      end
    end

    describe 'when updating a holiday' do
      describe 'when the start_date has changed' do
        let!(:term_1) { create(:term, calendar:, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23)) }
        let(:holiday) do
          create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          calendar.calendar_events.holidays.first
        end

        it 'moves a preceding term end date backwards' do
          expect(holiday_factory.with_neighbour_updates(holiday, { start_date: Date.new(2018, 3, 22) })).to eq(true)
          expect(term_1.reload.end_date).to eq(Date.new(2018, 3, 21))
        end

        it 'moves a preceding term end date forwards' do
          expect(holiday_factory.with_neighbour_updates(holiday, { start_date: Date.new(2018, 3, 25) })).to eq(true)
          expect(term_1.reload.end_date).to eq(Date.new(2018, 3, 24))
        end

        it 'deletes a preceding term when it is no longer valid' do
          expect(holiday_factory.with_neighbour_updates(holiday, { start_date: Date.new(2018, 3, 20) })).to eq(true)
          expect(calendar.calendar_events.terms.count).to eq(1)
        end

        context 'with a term and holiday separated by a gap (e.g. bank holiday)' do
          let!(:term_1) { create(:term, calendar:, start_date: Date.new(2018, 3, 2), end_date: Date.new(2018, 3, 23)) }
          let!(:holiday) do
            create(:calendar_event_holiday, calendar:, start_date: Date.new(2018, 3, 25), end_date: Date.new(2018, 4, 1))
          end

          it 'still moves the preceding term backwards with a gap for a bank holidays' do
            expect(holiday_factory.with_neighbour_updates(holiday, { start_date: Date.new(2018, 3, 20) })).to eq(true)
            expect(holiday.reload.start_date).to eq(Date.new(2018, 3, 20))
            expect(term_1.reload.end_date).to eq(Date.new(2018, 3, 19))
          end
        end
      end

      describe 'when the end_date has changed' do
        it 'moves a following term start date forwards' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(calendar.calendar_events.holidays.first, { end_date: Date.new(2018, 4, 20) })).to eq(true)
          term_2.reload
          expect(term_2.start_date).to eq(Date.new(2018, 4, 21))
        end

        it 'moves a following term start date backwards' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          term_2 = create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(calendar.calendar_events.holidays.first, { end_date: Date.new(2018, 4, 15) })).to eq(true)
          term_2.reload
          expect(term_2.start_date).to eq(Date.new(2018, 4, 16))
        end

        it 'deletes a following term when it is no longer valid' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 3, 20), end_date: Date.new(2018, 3, 23))
          create(:term, calendar: calendar, start_date: Date.new(2018, 4, 20), end_date: Date.new(2018, 5, 2))
          holiday_factory.create
          expect(holiday_factory.with_neighbour_updates(calendar.calendar_events.holidays.first, { end_date: Date.new(2018, 5, 2) })).to eq(true)
          expect(calendar.calendar_events.terms.count).to eq(1)
        end
      end
    end
  end
end

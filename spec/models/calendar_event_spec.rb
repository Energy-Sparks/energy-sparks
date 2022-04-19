require 'rails_helper'

describe CalendarEvent do

  let(:calendar)      { create(:calendar) }

  it 'sets its own academic year' do
    academic_year = create(:academic_year, start_date: Date.new(2019, 9, 1), end_date: Date.new(2020, 8, 31), calendar: calendar)
    event_2 = create(:holiday, calendar: calendar, start_date: Date.new(2020, 1, 22), end_date: Date.new(2020, 1, 30))
    expect(event_2 .academic_year).to eq(academic_year)
  end

  it 'creates a copy in child calendars' do
    child_calendar = create(:calendar, based_on: calendar)
    event = create(:holiday, calendar: calendar)
    expect(child_calendar.calendar_events.count).to eq(1)
    expect(child_calendar.calendar_events.last.based_on).to eq(event)
  end

  describe '#valid?' do

    it 'is valid with default attributes' do
      expect(build(:holiday, calendar: calendar)).to be_valid
    end

    describe 'date orders' do
      it 'is not valid when the end date and start date are in the wrong order' do
        expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 2, 2), end_date: Date.new(2018, 2, 1))).to_not be_valid
      end
    end

    describe 'overlapping event types' do
      describe 'for holidays' do
        it 'is not valid when there is another holiday with overlapping dates' do
          create(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).to_not be_valid
        end
        it 'is not valid when there is another term with overlapping dates' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).to_not be_valid
        end
        it 'is valid when the other does not overlap' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 31), end_date: Date.new(2018, 2, 1))).to be_valid
        end
        it 'is valid when the other is not of the right type' do
          create(:bank_holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 12), end_date: Date.new(2018, 2, 1))).to be_valid
        end
      end

      describe 'for terms' do
        it 'is not valid when there is another holiday with overlapping dates' do
          create(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).to_not be_valid
        end
        it 'is not valid when there is another term with overlapping dates' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).to_not be_valid
        end
        it 'is valid when the other does not overlap' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 31), end_date: Date.new(2018, 2, 1))).to be_valid
        end
        it 'is valid when the other is not of the right type' do
          create(:bank_holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 12), end_date: Date.new(2018, 2, 1))).to be_valid
        end
      end
    end

  end

end

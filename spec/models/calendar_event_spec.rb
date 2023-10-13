require 'rails_helper'

describe CalendarEvent do
  let(:calendar) { create(:calendar) }

  it 'sets its own academic year' do
    academic_year = create(:academic_year, start_date: Date.new(2019, 9, 1), end_date: Date.new(2020, 8, 31), calendar: calendar)
    event_2 = create(:holiday, calendar: calendar, start_date: Date.new(2020, 1, 22), end_date: Date.new(2020, 1, 30))
    expect(event_2.academic_year).to eq(academic_year)
  end

  describe '#valid?' do
    it 'is valid with default attributes' do
      expect(build(:holiday, calendar: calendar)).to be_valid
    end

    describe 'for national calendar' do
      let(:national_calendar) { create(:national_calendar) }

      it 'only bank holiday is valid' do
        expect(build(:holiday, calendar: national_calendar)).not_to be_valid
        expect(build(:term, calendar: national_calendar)).not_to be_valid
        expect(build(:bank_holiday, calendar: national_calendar)).to be_valid
      end
    end

    describe 'date orders' do
      it 'is not valid when the end date and start date are in the wrong order' do
        expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 2, 2), end_date: Date.new(2018, 2, 1))).not_to be_valid
      end
    end

    describe 'overlapping event types' do
      describe 'for holidays' do
        it 'is not valid when there is another holiday with overlapping dates' do
          create(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).not_to be_valid
        end

        it 'is not valid when there is another term with overlapping dates' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).not_to be_valid
        end

        it 'is valid when the other does not overlap' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 31), end_date: Date.new(2018, 2, 1))).to be_valid
        end

        it 'is valid when the other is not of the right type' do
          create(:inset_day, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 12), end_date: Date.new(2018, 2, 1))).to be_valid
        end
      end

      describe 'for terms' do
        it 'is not valid when there is another holiday with overlapping dates' do
          create(:holiday, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).not_to be_valid
        end

        it 'is not valid when there is another term with overlapping dates' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).not_to be_valid
        end

        it 'is valid when the other does not overlap' do
          create(:term, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 31), end_date: Date.new(2018, 2, 1))).to be_valid
        end

        it 'is valid when the other is not of the right type' do
          create(:inset_day, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 12), end_date: Date.new(2018, 2, 1))).to be_valid
        end
      end

      describe 'for same calendar type' do
        let(:calendar_event_type_1) { create(:calendar_event_type) }
        let(:calendar_event_type_2) { create(:calendar_event_type) }

        it 'is not valid when there is another event of same type with overlapping dates' do
          create(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_1, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_1, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).not_to be_valid
        end

        it 'is valid when there is another event of different type with overlapping dates' do
          create(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_1, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_2, start_date: Date.new(2018, 1, 23), end_date: Date.new(2018, 2, 1))).to be_valid
        end

        it 'is valid when there is another event of same type with non-overlapping dates' do
          create(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_1, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:calendar_event, calendar: calendar, calendar_event_type: calendar_event_type_1, start_date: Date.new(2018, 2, 1), end_date: Date.new(2018, 2, 2))).to be_valid
        end
      end
    end
  end
end

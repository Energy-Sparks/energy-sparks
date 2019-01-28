require 'rails_helper'

describe CalendarEvent do

  let(:calendar){ build(:calendar) }
  describe '#valid?' do

    it 'is valid with default attributes' do
      expect(build(:calendar_event, calendar: calendar)).to be_valid
    end

    describe 'date orders' do
      it 'is not valid when the end date and start date are in the wrong order' do
        expect(build(:calendar_event, calendar: calendar, start_date: Date.new(2018, 2, 2), end_date: Date.new(2018, 2, 1))).to_not be_valid
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
          create(:calendar_event, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
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
          create(:calendar_event, calendar: calendar, start_date: Date.new(2018, 1, 22), end_date: Date.new(2018, 1, 30))
          expect(build(:term, calendar: calendar, start_date: Date.new(2018, 1, 12), end_date: Date.new(2018, 2, 1))).to be_valid
        end
      end
    end

  end

end

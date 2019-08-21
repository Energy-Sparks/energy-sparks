require 'rails_helper'

describe CalendarAreaFactory do

  let(:events){
    [
      {
        term: '2015-2016 Term 1',
        start_date: '01/09/2015',
        end_date: '23/10/2015'
      }
    ]
  }

  let!(:bank_holiday) { create :bank_holiday, calendar_area: parent_area, title: 'Good Friday', holiday_date: "2012-04-06" }

  before do
    CalendarEventTypeFactory.create
    AcademicYearFactory.new(parent_area).create(start_year: 2011, end_year: 2016)
  end

  let(:populated_area) { CalendarArea.new({title: 'Oxfordshire', parent_area: parent_area}) }
  let(:parent_area){ create(:calendar_area, title: 'England') }
  let!(:area){ CalendarAreaFactory.create(populated_area, events) }

  it 'creates a calendar area' do
    expect(area.errors).to be_empty
    expect(area).to be_persisted
    expect(area.title).to eq('Oxfordshire')
  end

  it 'creates a template calendar for the area' do
    expect(area.calendars.count).to eq(1)
    expect(area.calendars.first.template?).to eq(true)
  end

  it 'processes the terms to create events for the calendar' do
    expect(area.calendars.first.calendar_events.terms.count).to eq(1)
  end

  describe 'when the area is not valid' do
    let(:populated_area) { CalendarArea.new({}) }

    it 'does not create any calendars or events' do
      expect(area.calendars.count).to eq(0)
    end

    it 'does not save the area' do
      expect(area).to_not be_persisted
    end
  end

  describe 'when the events are not valid' do
    let(:events){
      [
        {
          term: '2015-2016 Term 1',
          start_date: nil,
          end_date: nil
        }
      ]
    }

    it 'does not save the area, calendar or events' do
      expect(area).to_not be_persisted
      expect(area.calendars.count).to eq(0)
    end

    it 'puts an error on the area' do
      expect(area.errors[:base].first).to include("Start date can't be blank")
    end
  end
end

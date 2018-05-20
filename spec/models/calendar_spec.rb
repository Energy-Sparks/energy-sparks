require 'rails_helper'


describe Calendar do
  include CalendarData

  describe '.create_calendar_from_default' do
    let!(:area) { create(:area) }
    let!(:academic_years) { AcademicYearFactory.new(1990, 2023).create }
    let!(:calendar) { CalendarFactoryFromEventHash.new(CalendarData::EXAMPLE_CALENDAR_HASH, area) }

    it 'creates full calendar with academic years' do 
      pp calendar
    end
    # let(:title) { 'new calendar' }
    # it "creates a new calendar" do
    #   expect {
    #     Calendar.create_calendar_from_default(name)
    #   }.to change(Calendar, :count).by(1)
    # end
    # it "sets the name from the parameter" do
    #   calendar = Calendar.create_calendar_from_default(name)
    #   expect(calendar.name).to eq name
    # end
    # it "duplicates the terms from the default calendar (no school id)" do
    #   default_calendar = FactoryBot.create :calendar, default: true
    #   FactoryBot.create :term, calendar_id: default_calendar.id
    #   FactoryBot.create :term, calendar_id: default_calendar.id
    #   calendar = Calendar.create_calendar_from_default(name)
    #   expect(calendar.terms.count).to eq 2
    # end
  end
end

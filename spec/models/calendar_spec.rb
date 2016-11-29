require 'rails_helper'

describe Calendar do
  describe '.create_calendar_from_default' do
    let(:name) { 'new calendar' }
    it "creates a new calendar" do
      expect {
        Calendar.create_calendar_from_default(name)
      }.to change(Calendar, :count).by(1)
    end
    it "sets the name from the parameter" do
      calendar = Calendar.create_calendar_from_default(name)
      expect(calendar.name).to eq name
    end
    it "duplicates the terms from the default calendar (no school id)" do
      default_calendar = FactoryGirl.create :calendar
      FactoryGirl.create :term, calendar_id: default_calendar.id
      FactoryGirl.create :term, calendar_id: default_calendar.id
      calendar = Calendar.create_calendar_from_default(name)
      expect(calendar.terms.count).to eq 2
    end
  end
end

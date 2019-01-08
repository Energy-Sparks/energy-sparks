require 'rails_helper'

describe SchoolCreator, :schools, type: :service do

  describe '#process_new_school!' do
    let(:school){ create :school }
    let!(:alert_type){ create :alert_type }

    it 'populates the default opening times' do
      service = SchoolCreator.new(school)
      service.process_new_school!
      expect(school.school_times.count).to eq(5)
      expect(school.school_times.map(&:day)).to match_array(%w{monday tuesday wednesday thursday friday})
    end

    it 'adds alert_subscriptions to the school' do
      service = SchoolCreator.new(school)
      expect{
        service.process_new_school!
      }.to change{school.alert_subscriptions.count}.from(0).to(1)
      expect(school.alert_subscriptions.first.alert_type).to eq(alert_type)
    end

    it 'only adds alert subscriptions once' do
      service = SchoolCreator.new(school)
      service.process_new_school! # first call
      expect{
        service.process_new_school!
      }.to not_change{school.alert_subscriptions.count}
    end

  end

  describe '#process_new_school!' do
    let(:school){ create :school, calendar_area: calendar_area}

    let(:calendar_area) { create :calendar_area }
    let!(:calendar) { create :calendar_with_terms, template: true, calendar_area: calendar_area}

    it 'uses the calendar factory to create a calendar if there is one' do
      service = SchoolCreator.new(school)
      service.process_new_configuration!
      expect(school.calendar.based_on).to eq(calendar)
    end

    it 'leaves the calendar empty if there is no templaate for the area' do
      school.update(calendar_area: create(:calendar_area))
      service = SchoolCreator.new(school)
      service.process_new_configuration!
      expect(school.calendar).to be_nil
    end
  end

end

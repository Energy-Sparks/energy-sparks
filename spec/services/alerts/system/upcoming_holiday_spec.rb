require 'rails_helper'


describe Alerts::System::UpcomingHoliday do

  let(:calendar) { create :calendar }
  let!(:holiday) { create :holiday, start_date: start_date, end_date: start_date + 7.days, calendar: calendar }
  let(:school)  { create :school, calendar: calendar}

  let(:today){ Date.new(2019, 4, 26) }
  let(:report){ Alerts::System::UpcomingHoliday.new(school: school, today: today, alert_type: nil).report }

  context 'where the start date is in the next 7 days' do
    let(:start_date){ Date.new(2019, 4, 29) }

    it 'has a rating related to the number of days' do
      expect(report.rating).to eq(3.0)
    end
    it 'has a priority relevance related to the number of days' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(10)
    end
    it 'has a variable that represents the start date' do
      expect(report.template_data[:holiday_start_date]).to eq('29/04/2019')
    end
    it 'has a variable that represents the end date' do
      expect(report.template_data[:holiday_end_date]).to eq('06/05/2019')
    end
  end

  context 'where the start date is over 7 days away' do

    let(:start_date){ Date.new(2019, 10, 1) }

    it 'has a rating of 10' do
      expect(report.rating).to eq(nil)
    end

    it 'is not relevant' do
      expect(report.relevance).to eq(:not_relevant)
    end
    it 'has no variables' do
      expect(report.template_data).to be_empty
    end
  end

end


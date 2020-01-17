require 'rails_helper'

describe Alerts::System::MissingGasData do

  let(:school)  { create :school }
  let(:today) { Date.today }

  let(:report){ Alerts::System::MissingGasData.new(school: school, today: today, alert_type: nil).report }

  context 'where the school has gas data in the last 2 weeks' do

    let!(:meter){ create(:gas_meter_with_validated_reading_dates, start_date: 4.weeks.ago, end_date: 2.days.ago, school: school) }

    it 'has a rating of 10' do
      expect(report.rating).to eq(10.0)
    end
    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end
  end

  context 'where the gas data is from over 2 weeks ago' do

    let!(:meter){ create(:gas_meter_with_validated_reading_dates, start_date: 4.weeks.ago, end_date: 3.weeks.ago, school: school) }

    it 'has a rating related to the number of days late' do
      expect(report.rating).to eq(3.0)
    end

    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end

    it 'has the mpan_mprns as a variable' do
      expect(report.template_data[:mpan_mprns]).to eq("#{meter.mpan_mprn}")
    end

    context 'with much older readings' do
      let!(:meter){ create(:gas_meter_with_validated_reading_dates, start_date: 52.weeks.ago, end_date: 51.weeks.ago, school: school) }
      it 'has a rating of 0' do
        expect(report.rating).to eq(0.0)
      end
    end

  end

  context 'where there are no gas meters' do

    it 'has no rating' do
      expect(report.rating).to eq(nil)
    end

    it 'is never relevant' do
      expect(report.relevance).to eq(:never_relevant)
    end

  end

end

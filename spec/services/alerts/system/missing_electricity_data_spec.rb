require 'rails_helper'

describe Alerts::System::MissingElectricityData do
  let(:school)  { create :school }
  let(:today) { Time.zone.today }

  let(:report) { Alerts::System::MissingElectricityData.new(school: school, today: today, alert_type: nil).report }

  context 'where the school has electricity data in the last 2 weeks' do
    let!(:meter) { create(:electricity_meter_with_validated_reading_dates, start_date: 4.weeks.ago, end_date: 2.days.ago, school: school) }

    it 'has a rating of 10' do
      expect(report.rating).to eq(10.0)
    end

    it 'does not have mpan_mprns as a variable' do
      expect(report.template_data).to eq({})
      expect(report.template_data_cy).to eq({})
    end

    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end

    it 'has enough data' do
      expect(report.enough_data).to eq(:enough)
    end
  end

  context 'where the electricity data is from over 2 weeks ago' do
    let!(:meter) { create(:electricity_meter_with_validated_reading_dates, start_date: 4.weeks.ago, end_date: 3.weeks.ago, school: school) }

    it 'has a rating related to the number of days late' do
      expect(report.rating).to eq(3.0)
    end

    it 'has a priority relevance of 5' do
      expect(report.priority_data[:time_of_year_relevance]).to eq(5)
    end

    it 'has the mpan_mprns as a variable' do
      expect(report.template_data[:mpan_mprns]).to eq(meter.mpan_mprn.to_s)
      expect(report.template_data_cy[:mpan_mprns]).to eq(meter.mpan_mprn.to_s)
    end

    it 'has enough data' do
      expect(report.enough_data).to eq(:enough)
    end

    context 'with much older readings' do
      let!(:meter) { create(:electricity_meter_with_validated_reading_dates, start_date: 52.weeks.ago, end_date: 51.weeks.ago, school: school) }

      it 'has a rating of 0' do
        expect(report.rating).to eq(0.0)
      end
    end
  end

  context 'where there are no electricity meters' do
    it 'has no rating' do
      expect(report.rating).to eq(nil)
    end

    it 'has not enough data' do
      expect(report.enough_data).to eq(:not_enough)
    end

    it 'is never relevant' do
      expect(report.relevance).to eq(:never_relevant)
    end
  end
end

require 'rails_helper'

describe Schools::AnalysisDates do
  subject(:dates) { described_class.new(school, fuel_type) }

  let(:fuel_type) { :electricity }

  let(:start_date) { Date.new(2024, 1, 1) }
  let(:end_date) { Date.new(2024, 12, 31) }

  let(:school) do
    create(:school, :with_meter_dates, fuel_type: fuel_type, reading_start_date: start_date, reading_end_date: end_date)
  end

  describe '#start_date' do
    it { expect(dates.start_date).to eq start_date }
  end

  describe '#end_date' do
    it { expect(dates.end_date).to eq end_date }
  end

  describe '#analysis_date' do
    it { expect(dates.analysis_date).to eq end_date }

    context 'with solar' do
      let(:fuel_type) { :solar_pv }

      it { expect(dates.analysis_date).to eq Time.zone.today }
    end
  end

  describe '#one_years_data?' do
    it { expect(dates.one_years_data?).to be true }

    context 'with limited data' do
      let(:start_date) { Date.new(2024, 6, 1) }

      it { expect(dates.one_years_data?).to be false }
    end
  end

  describe '#recent_data' do
    it { expect(dates.recent_data).to be false }

    context 'when less than 30 days old' do
      before do
        travel_to(end_date + 29)
      end

      it { expect(dates.recent_data).to be true }
    end
  end

  describe '#months_of_data' do
    context 'with two years' do
      let(:start_date) { Date.new(2022, 12, 31) - 2.years }
      let(:end_date) { Date.new(2022, 12, 31) }

      it { expect(dates.months_of_data).to eq 24 }
    end

    context 'with just under two years' do
      let(:start_date) { Date.new(2022, 12, 31) - 2.years + 1.day }
      let(:end_date) { Date.new(2022, 12, 31) }

      it { expect(dates.months_of_data).to eq 23 }
    end
  end
end

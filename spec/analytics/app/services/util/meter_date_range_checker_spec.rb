# frozen_string_literal: true

require 'rails_helper'

describe Util::MeterDateRangeChecker, type: :service do
  let(:end_date)          { Date.today }
  let(:day_count)         { 365 }
  let(:meter)             do
    build(:meter, amr_data: build(:amr_data, :with_days, end_date: end_date, day_count: day_count))
  end
  let(:asof_date)         { Date.today }
  let(:service)           { described_class.new(meter, asof_date) }

  describe '#one_years_data?' do
    context 'with one years data' do
      it 'returns true' do
        expect(service.one_years_data?).to be true
      end
    end

    context 'with less than one years data' do
      let(:asof_date) { Date.today - 100 }

      it 'returns true' do
        expect(service.one_years_data?).to be false
      end
    end

    context 'when checking meter end date and theres enough data' do
      let(:asof_date) { nil }

      it 'returns true' do
        expect(service.one_years_data?).to be true
      end
    end

    context 'when checking meter end date and theres not enough data' do
      let(:asof_date)    { nil }
      let(:day_count)    { 100 }

      it 'returns false' do
        expect(service.one_years_data?).to be false
      end
    end
  end

  describe '#at_least_x_days_data?' do
    it 'returns expected value' do
      expect(service.at_least_x_days_data?(365)).to be true
    end

    context 'when checking meter end date and theres enough data' do
      let(:asof_date) { Date.today - 100 }

      it 'returns expected values' do
        expect(service.at_least_x_days_data?(365)).to be false
        expect(service.at_least_x_days_data?(30)).to be true
      end
    end
  end

  describe '#days_data_is_lagging' do
    it 'returns expected value' do
      expect(service.days_data_is_lagging).to eq 0
    end

    context 'when data is lagging' do
      let(:end_date) { Date.today - 45 }

      it 'returns expected value' do
        expect(service.days_data_is_lagging).to eq 45
      end
    end
  end

  describe '#recent_data?' do
    it 'returns expected value' do
      expect(service.recent_data?).to be true
    end

    context 'when data is lagging' do
      let(:end_date) { Date.today - 45 }

      it 'returns false' do
        expect(service.recent_data?).to be false
      end
    end
  end

  describe '#date_when_enough_data_available' do
    it 'returns expected value' do
      expect(service.date_when_enough_data_available(365)).to be nil
    end

    context 'when we have 200 days' do
      let(:day_count) { 200 }

      it 'returns false' do
        expect(service.date_when_enough_data_available(365)).to eq Date.today + 165
      end
    end
  end
end

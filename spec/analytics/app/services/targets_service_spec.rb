# frozen_string_literal: true

require 'rails_helper'

describe TargetsService do
  let(:meter_collection)        { build(:meter_collection) }
  let(:fuel_type)               { :electricity }
  let(:service)                 { described_class.new(meter_collection, fuel_type) }

  describe '#progress' do
    let(:august) { Date.new(2021, 8, 1) }
    let(:raw_data) do
      {
        current_year_kwhs: fill_array(100_000, 1111.11),
        full_targets_kwh: fill_array(100_000, 2222.22),
        partial_targets_kwh: fill_array(100_000, 3333),
        full_cumulative_current_year_kwhs: fill_array(100_000, 4444.44),
        full_cumulative_targets_kwhs: fill_array(100_000, 5555.55),
        partial_cumulative_targets_kwhs: fill_array(100_000, 6666),
        monthly_performance: fill_array(100, 77.77),
        cumulative_performance: fill_array(100, 88.88),
        cumulative_performance_versus_last_year: fill_array(100, 55.55),
        current_year_date_ranges: [
          dates('Tue, 01 Sep 2020', 'Wed, 30 Sep 2020'),
          dates('Thu, 01 Oct 2020', 'Sat, 31 Oct 2020'),
          dates('Sun, 01 Nov 2020', 'Mon, 30 Nov 2020'),
          dates('Tue, 01 Dec 2020', 'Thu, 31 Dec 2020'),
          dates('Fri, 01 Jan 2021', 'Sun, 31 Jan 2021'),
          dates('Mon, 01 Feb 2021', 'Sun, 28 Feb 2021'),
          dates('Mon, 01 Mar 2021', 'Wed, 31 Mar 2021'),
          dates('Thu, 01 Apr 2021', 'Fri, 30 Apr 2021'),
          dates('Sat, 01 May 2021', 'Mon, 31 May 2021'),
          dates('Tue, 01 Jun 2021', 'Wed, 30 Jun 2021'),
          dates('Thu, 01 Jul 2021', 'Sat, 31 Jul 2021'),
          dates('Sun, 01 Aug 2021', 'Tue, 17 Aug 2021')
        ],
        partial_months: [false, false, false, false, false, false,
                         false, false, false, false, false, true]
      }
    end

    let(:months) do
      [
        Date.new(2020, 9, 1),
        Date.new(2020, 10, 1),
        Date.new(2020, 11, 1),
        Date.new(2020, 12, 1),
        Date.new(2021, 1, 1),
        Date.new(2021, 2, 1),
        Date.new(2021, 3, 1),
        Date.new(2021, 4, 1),
        Date.new(2021, 5, 1),
        Date.new(2021, 6, 1),
        Date.new(2021, 7, 1),
        august
      ]
    end

    def dates(first, last)
      Date.parse(first)..Date.parse(last)
    end

    def fill_array(rand, last_item)
      Array.new(11) { rand(rand) } + [last_item]
    end

    before do
      allow_any_instance_of(CalculateMonthlyTrackAndTraceData).to receive(:raw_data).and_return(raw_data)
    end

    context 'with full year of data' do
      it 'returns months' do
        expect(service.progress.months).to match_array(months)
      end

      it 'returns monthly targets' do
        expect(service.progress.monthly_targets_kwh[august]).to eq(2222.22)
      end

      it 'returns monthly usage' do
        expect(service.progress.monthly_usage_kwh[august]).to eq(1111.11)
      end

      it 'returns monthly performance' do
        expect(service.progress.monthly_performance[august]).to eq(77.77)
      end

      it 'returns cumulative targets' do
        expect(service.progress.cumulative_targets_kwh[august]).to eq(5555.55)
      end

      it 'returns cumulative usage' do
        expect(service.progress.cumulative_usage_kwh[august]).to eq(4444.44)
      end

      it 'returns cumulative_performance' do
        expect(service.progress.cumulative_performance[august]).to eq(88.88)
      end

      it 'returns fuel type' do
        expect(service.progress.fuel_type).to eq(:electricity)
      end

      it 'returns partial months' do
        expect(service.progress.partial_months[august]).to eq(true)
      end

      it 'returns current cumulative performance vs synthetic' do
        expect(service.progress.current_cumulative_performance_versus_synthetic_last_year).to eq(55.55)
      end

      it 'returns current cumulative consumption' do
        expect(service.progress.current_cumulative_usage_kwh).to eq(4444.44)
      end
    end

    context 'with no recent data' do
      before do
        raw_data[:full_cumulative_current_year_kwhs] = Array.new(6) { rand(100_000) } + [777, nil, nil, nil, nil, nil]
        raw_data[:cumulative_performance_versus_last_year] = Array.new(6) { rand(100) } + [66, nil, nil, nil, nil, nil]
      end

      it 'returns the most recent values' do
        expect(service.progress.current_cumulative_usage_kwh).to eq(777)
        expect(service.progress.current_cumulative_performance_versus_synthetic_last_year).to eq(66)
      end
    end
  end

  describe '#enough_data' do
    before do
      allow_any_instance_of(described_class).to receive(:enough_holidays?).and_return(true)
      allow_any_instance_of(described_class).to receive(:enough_temperature_data?).and_return(true)
      allow_any_instance_of(described_class).to receive(:enough_readings_to_calculate_target?).and_return(true)
    end

    it 'is enabled by default' do
      expect(service.enough_data_to_set_target?).to be true
    end

    it 'can be disabled by feature flag' do
      allow(ENV).to receive(:[]).with('FEATURE_FLAG_TARGETS_DISABLE_ELECTRICITY').and_return('true')
      expect(service.enough_data_to_set_target?).to be false
    end

    it 'can be enabled by feature flag' do
      allow(ENV).to receive(:[]).with('FEATURE_FLAG_TARGETS_DISABLE_ELECTRICITY').and_return('false')
      expect(service.enough_data_to_set_target?).to be true
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe TargetsProgress do
  let(:january)                   { Date.new(Date.today.year, 1, 1) }
  let(:february)                  { Date.new(Date.today.year, 2, 1) }
  let(:months)                    { [january, february] }
  let(:fuel_type)                 { :electricity }

  let(:monthly_usage_kwh)         { [10, 20] }
  let(:monthly_targets_kwh)       { [8, 15] }
  let(:monthly_performance)       { [-0.25, 0.35] }

  let(:cumulative_usage_kwh)      { [10, 30] }
  let(:cumulative_targets_kwh)    { [8, 25] }
  let(:cumulative_performance)    { [-0.99, 0.99] }

  let(:partial_months)            { [false, true] }
  let(:percentage_synthetic)      { [0.0, 0.5] }

  let(:progress) do
    described_class.new(
      fuel_type: fuel_type,
      months: months,
      monthly_targets_kwh: monthly_targets_kwh,
      monthly_usage_kwh: monthly_usage_kwh,
      monthly_performance: monthly_performance,
      cumulative_targets_kwh: cumulative_targets_kwh,
      cumulative_usage_kwh: cumulative_usage_kwh,
      cumulative_performance: cumulative_performance,
      cumulative_performance_versus_synthetic_last_year: cumulative_performance,
      monthly_performance_versus_synthetic_last_year: monthly_performance,
      partial_months: partial_months,
      percentage_synthetic: percentage_synthetic
    )
  end

  describe '#monthly_targets_kwh' do
    it 'returns expected data' do
      expect(progress.monthly_targets_kwh[january]).to eq 8
      expect(progress.monthly_targets_kwh[february]).to eq 15
    end
  end

  describe '#monthly_usage_kwh' do
    it 'returns expected data' do
      expect(progress.monthly_usage_kwh[january]).to eq 10
      expect(progress.monthly_usage_kwh[february]).to eq 20
    end
  end

  describe '#monthly_performance' do
    it 'returns expected data' do
      expect(progress.monthly_performance[january]).to eq(-0.25)
      expect(progress.monthly_performance[february]).to eq 0.35
    end
  end

  describe '#cumulative_usage_kwh' do
    it 'returns expected data' do
      expect(progress.cumulative_usage_kwh[january]).to eq 10
      expect(progress.cumulative_usage_kwh[february]).to eq 30
    end
  end

  describe '#cumulative_targets_kwh' do
    it 'returns expected data' do
      expect(progress.cumulative_targets_kwh[january]).to eq 8
      expect(progress.cumulative_targets_kwh[february]).to eq 25
    end
  end

  describe '#cumulative_performance' do
    it 'returns expected data' do
      expect(progress.cumulative_performance[january]).to be(-0.99)
      expect(progress.cumulative_performance[february]).to be 0.99
    end
  end

  describe '#percentage_synthetic' do
    it 'returns expected data' do
      expect(progress.percentage_synthetic[january]).to be 0.0
      expect(progress.percentage_synthetic[february]).to be 0.5
    end
  end

  describe '#partial_months' do
    it 'returns expected data' do
      expect(progress.partial_months[january]).to eq false
      expect(progress.partial_months[february]).to eq true
    end
  end

  describe '#current_cumulative_usage_kwh' do
    it 'returns expected data' do
      expect(progress.current_cumulative_usage_kwh).to eq 30
    end
  end

  describe '#current_cumulative_performance' do
    it 'returns expected data' do
      expect(progress.current_cumulative_performance).to eq 0.99
    end
  end

  describe '#months' do
    it 'returns expected data' do
      expect(progress.months).to eq [january, february]
    end
  end

  describe '#partial_consumption_data?' do
    it 'returns expected data' do
      expect(progress.partial_consumption_data?).to be true
    end
  end

  describe '#partial_target_data?' do
    it 'returns expected data' do
      expect(progress.partial_target_data?).to be false
    end
  end

  describe '#reporting_period_before_consumption_data?' do
    it 'returns expected data' do
      expect(progress.reporting_period_before_consumption_data?).to be false
    end
  end

  describe '#targets_derived_from_synthetic_data?' do
    it 'returns expected data' do
      expect(progress.targets_derived_from_synthetic_data?).to be true
    end
  end
end

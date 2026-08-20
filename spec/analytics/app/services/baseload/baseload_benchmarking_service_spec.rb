# frozen_string_literal: true

require 'rails_helper'

describe Baseload::BaseloadBenchmarkingService, type: :service do
  subject(:service) { described_class.new(meter_collection, asof_date) }

  let(:asof_date) { Date.new(2025, 12, 31) }

  # using fixed generation (from context) and consumption to simplify calculating expected values
  let(:consumption_x48) { [*([0.1] * 10), *([0.005] * 10), *([0.4] * 8), *([0.25] * 10), *([0.01] * 10)] }

  include_context 'with an aggregated meter with tariffs and school times' do
    let(:amr_start_date)  { Date.new(2024, 1, 1) }
    let(:amr_end_date)    { asof_date }

    let(:amr_data) do
      build(:amr_data, :with_date_range, :with_grid_carbon_intensity,
            grid_carbon_intensity: grid_carbon_intensity,
            start_date: amr_start_date,
            end_date: amr_end_date,
            kwh_data_x48: consumption_x48)
    end
  end

  describe '#average_baseload_kw' do
    context 'with a well managed benchmark' do
      let(:expected_baseload) do
        BenchmarkMetrics.recommended_baseload_for_pupils(pupils: 1000,
                                                         school_type: :primary,
                                                         heat_pump: false)
      end

      it 'calculates baseload for a benchmark school' do
        expect(service.average_baseload_kw(compare: :benchmark_school)).to be_within(0.01).of(expected_baseload)
      end
    end

    context 'with an exemplar benchmark' do
      let(:expected_baseload) do
        BenchmarkMetrics.exemplar_baseload_for_pupils(pupils: 1000,
                                                      school_type: :primary,
                                                      heat_pump: false)
      end

      it 'calculates baseload for a benchmark school' do
        expect(service.average_baseload_kw(compare: :exemplar_school)).to be_within(0.01).of(expected_baseload)
      end
    end
  end

  describe '#baseload_usage' do
    context 'with a well managed benchmark' do
      subject(:usage) { service.baseload_usage(compare: :benchmark_school) }

      let(:expected_baseload_kwh) do
        BenchmarkMetrics.recommended_baseload_for_pupils(pupils: 1000, school_type: :primary,
                                                         heat_pump: false) * 365 * 24
      end

      it 'calculates usage' do
        expect(usage.kwh).to be_within(0.01).of(expected_baseload_kwh)
        expect(usage.£).to be_within(0.01).of(expected_baseload_kwh * flat_rate) # rubocop:disable Naming/AsciiIdentifiers
        expect(usage.co2).to be_within(0.01).of(expected_baseload_kwh * carbon_intensity)
      end
    end

    context 'with an exemplar benchmark' do
      subject(:usage) { service.baseload_usage(compare: :exemplar_school) }

      let(:expected_baseload_kwh) do
        BenchmarkMetrics.exemplar_baseload_for_pupils(pupils: 1000, school_type: :primary, heat_pump: false) * 365 * 24
      end

      it 'calculates usage' do
        expect(usage.kwh).to be_within(0.01).of(expected_baseload_kwh)
        expect(usage.£).to be_within(0.01).of(expected_baseload_kwh * flat_rate) # rubocop:disable Naming/AsciiIdentifiers
        expect(usage.co2).to be_within(0.01).of(expected_baseload_kwh * carbon_intensity)
      end
    end
  end

  describe '#estimated_savings' do
    let(:expected_savings_kwh) do
      actual_baseload_kwh = 0.01 * 365 * 24 # 0.01 is baseload from consumption_x48
      actual_baseload_kwh - expected_baseload_kwh
    end

    context 'with a well managed benchmark' do
      subject(:usage) { service.estimated_savings(versus: :benchmark_school) }

      let(:expected_baseload_kwh) do
        BenchmarkMetrics.recommended_baseload_for_pupils(pupils: 1000, school_type: :primary,
                                                         heat_pump: false) * 365 * 24
      end

      it 'calculates savings' do
        expect(usage.kwh).to be_within(0.01).of(expected_savings_kwh)
        expect(usage.£).to be_within(0.01).of(expected_savings_kwh * flat_rate) # rubocop:disable Naming/AsciiIdentifiers
        expect(usage.co2).to be_within(0.01).of(expected_savings_kwh * carbon_intensity)
      end
    end

    context 'with an exemplar benchmark' do
      subject(:usage) { service.estimated_savings(versus: :exemplar_school) }

      let(:expected_baseload_kwh) do
        BenchmarkMetrics.exemplar_baseload_for_pupils(pupils: 1000, school_type: :primary, heat_pump: false) * 365 * 24
      end

      it 'calculates savings' do
        expect(usage.kwh).to be_within(0.01).of(expected_savings_kwh)
        expect(usage.£).to be_within(0.01).of(expected_savings_kwh * flat_rate) # rubocop:disable Naming/AsciiIdentifiers
        expect(usage.co2).to be_within(0.01).of(expected_savings_kwh * carbon_intensity)
      end
    end
  end

  describe '#enough_data?' do
    context 'when theres is a years worth' do
      it 'returns true' do
        expect(service.enough_data?).to be true
        expect(service.data_available_from).to be_nil
      end
    end

    context 'when theres is limited data' do
      let(:asof_date) {  Date.new(2024, 1, 13) }

      it 'returns false' do
        expect(service.enough_data?).to be false
        expect(service.data_available_from).not_to be_nil
      end
    end
  end
end

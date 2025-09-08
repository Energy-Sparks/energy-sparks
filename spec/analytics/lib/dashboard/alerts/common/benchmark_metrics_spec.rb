# frozen_string_literal: true

require 'rails_helper'
require 'dashboard'

describe BenchmarkMetrics do
  describe '.benchmark_annual_electricity_usage_kwh' do
    let(:pupils) { 10 }
    let(:annual_usage_kwh) do
      stub_const('BenchmarkMetrics::BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL', 219)
      BenchmarkMetrics.benchmark_annual_electricity_usage_kwh(school_type, pupils)
    end

    context 'with a primary school' do
      let(:school_type) { :primary }

      it 'returns the expected value' do
        expect(annual_usage_kwh).to eq pupils * 219
      end
    end

    context 'with a secondary school' do
      let(:school_type) { :secondary }

      it 'returns the expected value' do
        expect(annual_usage_kwh).to eq pupils * 219.0 * 1.7
      end
    end

    context 'with a special school' do
      let(:school_type) { :special }

      it 'returns the expected value' do
        stub_const('BenchmarkMetrics::BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL', 868)
        expect(annual_usage_kwh).to eq pupils * 868
      end
    end

    context 'with an unknown school type' do
      let(:school_type) { :unknown }

      it 'throws an exception' do
        expect { annual_usage_kwh }.to raise_error(EnergySparksUnexpectedStateException)
      end
    end
  end

  describe '.exemplar_annual_electricity_usage_kwh' do
    let(:pupils) { 10 }
    let(:annual_usage_kwh) do
      stub_const('BenchmarkMetrics::EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL', 196)
      BenchmarkMetrics.exemplar_annual_electricity_usage_kwh(school_type, pupils)
    end

    context 'with a primary school' do
      let(:school_type) { :primary }

      it 'returns the expected value' do
        expect(annual_usage_kwh).to eq pupils * 196
      end
    end

    context 'with a secondary school' do
      let(:school_type) { :secondary }

      it 'returns the expected value' do
        expect(annual_usage_kwh).to eq pupils * 196 * 1.7
      end
    end

    context 'with a special school' do
      let(:school_type) { :special }

      it 'returns the expected value' do
        stub_const('BenchmarkMetrics::EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL_SPECIAL_SCHOOL', 663)
        expect(annual_usage_kwh).to eq pupils * 663
      end
    end

    context 'with an unknown school type' do
      let(:school_type) { :unknown }

      it 'throws an exception' do
        expect { annual_usage_kwh }.to raise_error(EnergySparksUnexpectedStateException)
      end
    end
  end

  describe '.benchmark_energy_usage_£_per_pupil' do
    let(:meter_collection) { build(:meter_collection) }

    let(:amr_start_date)  { Date.new(2022, 1, 1) }
    let(:amr_end_date)    { Date.new(2022, 12, 31) }
    let(:amr_data) { build(:amr_data, :with_date_range, start_date: amr_start_date, end_date: amr_end_date) }

    let(:meter) { build(:meter, :with_flat_rate_tariffs, amr_data: amr_data, tariff_start_date: amr_start_date, tariff_end_date: amr_end_date) }

    let(:benchmark_type) { :benchmark }
    let(:asof_date) { Date.new(2022, 12, 31) }

    let(:energy_usage_£_per_pupil) do
      BenchmarkMetrics.benchmark_energy_usage_£_per_pupil(benchmark_type, meter_collection, asof_date, list_of_fuels)
    end

    context 'when only electricity requested' do
      before do
        allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(meter)
      end

      let(:list_of_fuels) { [:electricity] }

      it 'returns the benchmark value' do
        # BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL * the flat rate above
        stub_const('BenchmarkMetrics::BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL', 219)
        expect(energy_usage_£_per_pupil).to be_within(0.1).of(219.0 * 0.1)
      end

      context 'with :exemplar benchmark' do
        let(:benchmark_type) { :exemplar }

        it 'returns the exemplar benchmark value' do
          # EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL * the flat rate above
          stub_const('BenchmarkMetrics::EXEMPLAR_ELECTRICITY_USAGE_PER_PUPIL', 196)
          expect(energy_usage_£_per_pupil).to be_within(0.1).of(196.0 * 0.1)
        end
      end
    end

    context 'when only gas requested' do
      before do
        allow(BenchmarkMetrics).to receive(:normalise_degree_days).and_return(degree_day_adjustment)
        allow(meter_collection).to receive(:aggregated_heat_meters).and_return(meter)
      end

      let(:degree_day_adjustment) { 1.0 }
      let(:list_of_fuels) { [:gas] }

      it 'returns the benchmark value' do
        # BENCHMARK_GAS_USAGE_PER_PUPIL / degree_day_adjustment * the flat rate above
        stub_const('BenchmarkMetrics::BENCHMARK_GAS_USAGE_PER_PUPIL', 430)
        expect(energy_usage_£_per_pupil).to be_within(0.1).of(430 * 0.1)
      end

      context 'with :exemplar benchmark' do
        let(:benchmark_type) { :exemplar }

        it 'returns the exemplar benchmark value' do
          # TODO: not sure this is the right variable it should be using
          # EXEMPLAR_GAS_USAGE_PER_M2  / degree_day_adjustment * the flat rate above
          stub_const('BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2', 55)
          expect(energy_usage_£_per_pupil).to be_within(0.1).of(55.0 * 0.1)
        end
      end
    end

    context 'when storage heaters requested' do
      before do
        allow(BenchmarkMetrics).to receive(:normalise_degree_days).and_return(degree_day_adjustment)
        allow(meter_collection).to receive(:storage_heater_meter).and_return(meter)
        allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(meter)
      end

      let(:degree_day_adjustment) { 1.0 }
      let(:list_of_fuels) { [:storage_heaters] }

      it 'returns the benchmark value' do
        # BENCHMARK_GAS_USAGE_PER_PUPIL / degree_day_adjustment * the flat rate above
        stub_const('BenchmarkMetrics::BENCHMARK_GAS_USAGE_PER_PUPIL', 430)
        expect(energy_usage_£_per_pupil).to be_within(0.1).of(430.0 * 0.1)
      end

      context 'with :exemplar benchmark' do
        let(:benchmark_type) { :exemplar }

        it 'returns the exemplar benchmark value' do
          # TODO: not sure this is the right variable it should be using
          # EXEMPLAR_GAS_USAGE_PER_M2  / degree_day_adjustment * the flat rate above
          stub_const('BenchmarkMetrics::EXEMPLAR_GAS_USAGE_PER_M2', 55)
          expect(energy_usage_£_per_pupil).to be_within(0.1).of(55.0 * 0.1)
        end
      end
    end

    context 'when two fuel types requested' do
      before do
        allow(BenchmarkMetrics).to receive(:normalise_degree_days).and_return(degree_day_adjustment)
        allow(meter_collection).to receive(:storage_heater_meter).and_return(meter)
        allow(meter_collection).to receive(:aggregated_electricity_meters).and_return(meter)
        stub_const('BenchmarkMetrics::BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL', 219)
        stub_const('BenchmarkMetrics::BENCHMARK_GAS_USAGE_PER_PUPIL', 430)
      end

      let(:degree_day_adjustment) { 1.0 }
      let(:list_of_fuels) { %i[electricity storage_heaters] }

      let(:expected_electricity)     { 219.0 * 0.1 } # BENCHMARK_ELECTRICITY_USAGE_PER_PUPIL
      let(:expected_storage_heaters) { 430.0 * 0.1 } # BENCHMARK_GAS_USAGE_PER_PUPIL?

      it 'adds the values' do
        expect(energy_usage_£_per_pupil).to be_within(0.1).of(expected_electricity + expected_storage_heaters)
      end
    end
  end
end

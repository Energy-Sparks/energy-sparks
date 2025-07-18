# frozen_string_literal: true

require 'rails_helper'

describe Usage::AnnualUsageBenchmarksService, :aggregate_failures, type: :service do
  let(:fuel_type) { :electricity }

  # AMR data for the school
  let(:kwh_data_x48)    { Array.new(48) { 10.0 } }
  let(:amr_start_date)  { Date.new(2021, 12, 31) }
  let(:amr_end_date)    { Date.new(2022, 12, 31) }
  let(:amr_data) { build(:amr_data, :with_date_range, :with_grid_carbon_intensity, grid_carbon_intensity: grid_carbon_intensity, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: kwh_data_x48) }

  # Carbon intensity used to calculate co2 emissions
  let(:grid_carbon_intensity) { build(:grid_carbon_intensity, :with_days, start_date: amr_start_date, end_date: amr_end_date, kwh_data_x48: Array.new(48) { 0.2 }) }

  let(:degree_day_adjustment) { 1.0 }

  # Meter to use as the aggregate
  let(:meter) { build(:meter, :with_flat_rate_tariffs, type: fuel_type, amr_data: amr_data, tariff_start_date: amr_start_date, tariff_end_date: amr_end_date) }

  # primary school, with 1000 pupils and 5000 sq m2 by default
  let(:meter_collection) { build(:meter_collection) }

  let(:asof_date)        { Date.new(2022, 12, 31) }

  let(:service)          { Usage::AnnualUsageBenchmarksService.new(meter_collection, fuel_type, asof_date) }

  before do
    allow(meter_collection).to receive(:aggregate_meter).and_return(meter)
    allow(BenchmarkMetrics).to receive(:normalise_degree_days).and_return(degree_day_adjustment)
    # TODO: this could be moved to factory
    meter.set_tariffs
  end

  describe '#enough_data?' do
    context 'with electricity' do
      context 'with enough data' do
        it 'returns true' do
          expect(service.enough_data?).to be true
        end
      end

      context 'with limited data' do
        let(:amr_start_date) { Date.new(2022, 12, 1) }

        it 'returns false' do
          expect(service.enough_data?).to be false
        end
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      context 'when there is enough data' do
        context 'with limited data' do
          let(:amr_start_date) { Date.new(2022, 12, 1) }

          it 'returns false' do
            expect(service.enough_data?).to be false
          end
        end

        it 'returns true' do
          expect(service.enough_data?).to be true
        end
      end
    end
  end

  describe '#annual_usage' do
    context 'with electricity' do
      it 'calculates the expected values for a benchmark school' do
        annual_usage = service.annual_usage(compare: :benchmark_school)
        expect(annual_usage.kwh).to be_within(0.01).of(219_000.0)
        expect(annual_usage.co2).to be_within(0.01).of(43_800.0) # 0.2 * kwh
        expect(annual_usage.£).to be_within(0.01).of(21_900.0) # 0.1 * kwh
      end

      it 'calculates the expected values for an exemplar school' do
        annual_usage = service.annual_usage(compare: :exemplar_school)
        expect(annual_usage.kwh).to be_within(0.01).of(196_000.0)
        expect(annual_usage.co2).to be_within(0.01).of(39_200.0) # 0.2 * kwh
        expect(annual_usage.£).to be_within(0.01).of(19_600.0) # 0.1 * kwh
      end
    end

    context 'with gas' do
      let(:fuel_type)     { :gas }
      let(:kwh_data_x48)  { Array.new(48) { 5.0 } }

      it 'calculates the expected values for a benchmark school' do
        annual_usage = service.annual_usage(compare: :benchmark_school)
        expect(annual_usage.kwh).to be_within(0.01).of(320_000.0)
        expect(annual_usage.co2).to be_within(0.01).of(64_000.0) # 0.2 * kwh
        expect(annual_usage.£).to be_within(0.01).of(32_000.0) # 0.1 * kwh
      end

      it 'calculates the expected values for an exemplar school' do
        annual_usage = service.annual_usage(compare: :exemplar_school)
        expect(annual_usage.kwh).to be_within(0.01).of(275_000.0)
        expect(annual_usage.co2).to be_within(0.01).of(55_000.0) # 0.2 * kwh
        expect(annual_usage.£).to be_within(0.01).of(27_500.0) # 0.1 * kwh
      end
    end
  end

  describe '#estimate_savings' do
    context 'with electricity' do
      it 'calculates the expected values for a benchmark school' do
        savings = service.estimated_savings(versus: :benchmark_school)
        expect(savings.kwh).to be_within(0.01).of(44_280.0)
        expect(savings.£).to be_within(0.01).of(4428.0)
        expect(savings.co2).to be_within(0.01).of(8856.0)
        expect(savings.percent).to be_within(0.01).of(-0.20)
      end

      it 'calculates the expected values for an exemplar school' do
        savings = service.estimated_savings(versus: :exemplar_school)
        expect(savings.kwh).to be_within(0.01).of(21_280.0)
        expect(savings.£).to be_within(0.01).of(2128.0)
        expect(savings.co2).to be_within(0.01).of(4256.0)
        expect(savings.percent).to be_within(0.01).of(-0.11)
      end
    end

    context 'with gas' do
      let(:fuel_type) { :gas }

      it 'calculates the expected values for a benchmark school' do
        savings = service.estimated_savings(versus: :benchmark_school)
        expect(savings.kwh).to be_within(0.01).of(145_280.0)
        expect(savings.£).to be_within(0.01).of(14_528.0)
        expect(savings.co2).to be_within(0.01).of(29_056.0)
        expect(savings.percent).to be_within(0.01).of(-0.45)
      end

      it 'calculates the expected values for an exemplar school' do
        savings = service.estimated_savings(versus: :exemplar_school)
        expect(savings.kwh).to be_within(0.01).of(100_280.0)
        expect(savings.£).to be_within(0.01).of(10_028.0)
        expect(savings.co2).to be_within(0.01).of(20_056.0)
        expect(savings.percent).to be_within(0.01).of(-0.36)
      end
    end
  end
end

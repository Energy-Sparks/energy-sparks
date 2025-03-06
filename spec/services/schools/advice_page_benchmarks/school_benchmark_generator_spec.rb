require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator, type: :service do
  let(:school) { create(:school) }
  let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: true, has_gas: true, has_storage_heaters: true)}

  let(:advice_page) { create(:advice_page, key: :baseload, fuel_type: :electricity) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service) { Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  describe '.can_benchmark?' do
    let(:result) { Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.can_benchmark?(advice_page: advice_page)}

    context 'for existing benchmarks' do
      [:baseload, :electricity_long_term, :gas_long_term, :electricity_out_of_hours, :gas_out_of_hours, :electricity_intraday, :thermostatic_control, :heating_control].each do |key|
        let(:advice_page) { create(:advice_page, key: key) }
        it "returns true for #{key}" do
          expect(result).to eq true
        end
      end
    end

    context 'for unknown benchmark' do
      let(:advice_page) { create(:advice_page, key: :unknown) }

      it 'returns false' do
        expect(result).to eq false
      end
    end
  end

  describe '.generator_for' do
    let(:generator) { Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.generator_for(advice_page: advice_page, school: school, aggregate_school: aggregate_school) }

    it 'returns object for known generator' do
      expect(generator).not_to be_nil
      expect(generator.class).to eq Schools::AdvicePageBenchmarks::BaseloadBenchmarkGenerator
    end

    context 'for unknown key' do
      let(:advice_page) { create(:advice_page, key: :unknown) }

      it 'returns nil for unknown generator' do
        expect(generator).to be_nil
      end
    end
  end

  describe '#perform' do
    let(:result) { service.perform }

    before do
      school.configuration.update!(fuel_configuration: fuel_configuration)
    end

    context 'when an error occurs' do
      before do
        allow(service).to receive(:benchmark_school).and_raise
      end

      it 'logs rollbar' do
        expect(Rollbar).to receive(:error)
        service.perform
      end
    end

    context 'when school doesnt have fuel type' do
      let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: false, has_gas: true, has_storage_heaters: true)}

      before do
        allow(service).to receive(:benchmark_school).and_return(:exemplar_school)
      end

      it 'doesnt generate a benchmark' do
        expect(result).to be_nil
      end
    end

    context 'with no benchmark' do
      it 'doesnt create record if benchmarked_as is nil' do
        expect(result).to be_nil
        expect(AdvicePageSchoolBenchmark.count).to eq 0
      end

      context 'and a benchmark is generated' do
        before do
          allow(service).to receive(:benchmark_school).and_return(:exemplar_school)
        end

        it 'creates benchmark' do
          expect(result).not_to be_nil
          expect(result.advice_page).to eq advice_page
          expect(result.school).to eq school
          expect(result.benchmarked_as).to eq 'exemplar_school'
        end
      end
    end

    context 'with existing benchmark' do
      let!(:benchmark) { create(:advice_page_school_benchmark, school: school, advice_page: advice_page, benchmarked_as: :other_school)}

      before do
        school.reload
      end

      context 'and a benchmark is generated' do
        before do
          allow(service).to receive(:benchmark_school).and_return(:exemplar_school)
        end

        it 'updates the benchmark' do
          expect(result).to eq benchmark
          benchmark.reload
          expect(benchmark.benchmarked_as).to eq 'exemplar_school'
        end
      end

      context 'and benchmark is nil' do
        it 'removes the benchmark' do
          expect(result).to eq nil
          expect(AdvicePageSchoolBenchmark.count).to eq 0
        end
      end

      context 'and school no longer has fuel type' do
        let!(:fuel_configuration) { Schools::FuelConfiguration.new(has_electricity: false, has_gas: true, has_storage_heaters: true)}

        it 'removes the benchmark' do
          expect(result).to eq nil
          expect(AdvicePageSchoolBenchmark.count).to eq 0
        end
      end
    end
  end
end

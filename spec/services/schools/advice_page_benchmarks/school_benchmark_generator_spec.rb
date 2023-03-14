require 'rails_helper'
RSpec.describe Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator, type: :service do

  let(:school)      { create(:school) }
  let(:advice_page) { create(:advice_page, key: :baseload) }
  let(:aggregate_school) { double(:aggregate_school) }

  let(:service)     { Schools::AdvicePageBenchmarks::SchoolBenchmarkGenerator.new(advice_page: advice_page, school: school, aggregate_school: aggregate_school)}

  context '#perform' do
    let(:result)      { service.perform }

    context 'when an error occurs' do
      before(:each) do
        allow(service).to receive(:benchmark_school).and_raise
      end
      it 'logs rollbar' do
        expect(Rollbar).to receive(:error)
        service.perform
      end
    end
    context 'with no benchmark' do
      it 'doesnt create record if benchmarked_as is nil' do
        expect(result).to be_nil
        expect(AdvicePageSchoolBenchmark.count).to eq 0
      end
      context 'and a benchmark is generated' do
        before(:each) do
          allow(service).to receive(:benchmark_school).and_return(:exemplar)
        end
        it 'creates benchmark' do
          expect(result).to_not be_nil
          expect(result.advice_page).to eq advice_page
          expect(result.school).to eq school
          expect(result.benchmarked_as).to eq "exemplar"
        end
      end
    end
    context 'with existing benchmark' do
      let!(:benchmark) { create(:advice_page_school_benchmark, school: school, advice_page: advice_page, benchmarked_as: :improving)}

      before(:each) do
        school.reload
      end

      context 'and a benchmark is generated' do
        before(:each) do
          allow(service).to receive(:benchmark_school).and_return(:exemplar)
        end
        it 'updates the benchmark' do
          expect(result).to eq benchmark
          benchmark.reload
          expect(benchmark.benchmarked_as).to eq "exemplar"
        end
      end
      context 'and benchmark is nil' do
        it 'removes the benchmark' do
          expect(result).to eq nil
          expect(AdvicePageSchoolBenchmark.count).to eq 0
        end
      end
    end
  end
end

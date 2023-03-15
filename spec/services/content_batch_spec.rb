require 'rails_helper'

describe ContentBatch do

  let!(:school_1) { create(:school) }
  let!(:school_2) { create(:school) }

  it 'should continue processing if batch fails for a single school' do
    expect(AggregateSchoolService).to receive(:new).twice.and_raise(ArgumentError)
    ContentBatch.new.generate
  end

  it 'should regenerate using latest benchmark' do
    benchmark_result_generation_run_1 = BenchmarkResultGenerationRun.create!
    benchmark_result_generation_run_2 = BenchmarkResultGenerationRun.create!
    ContentBatch.new.regenerate
    expect(BenchmarkResultSchoolGenerationRun.last.benchmark_result_generation_run).to eq(benchmark_result_generation_run_2)
  end

  context 'when school has a target' do
    let!(:school_target) { create(:school_target, school: school_1) }
    it 'should end up updated' do
      ContentBatch.new.generate
      school_target.reload
      expect(school_target.report_last_generated).to_not be_nil
    end
  end

  context 'it should run advice page benchmarks' do
    let(:stub)    { double('generator') }
    before(:each) do
      expect(Schools::AdvicePageBenchmarks::GenerateBenchmarks).to receive(:new).with(school: school_1, aggregate_school: anything).and_return(stub)
      expect(Schools::AdvicePageBenchmarks::GenerateBenchmarks).to receive(:new).with(school: school_2, aggregate_school: anything).and_return(stub)
      expect(stub).to receive(:generate!).twice
    end
    it 'runs the benchmarks' do
      ContentBatch.new.generate
    end
  end
end

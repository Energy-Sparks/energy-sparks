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

end

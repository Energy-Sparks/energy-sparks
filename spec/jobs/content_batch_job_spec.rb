require 'rails_helper'

describe ContentBatchJob do

  let!(:school_1) { create(:school) }
  let!(:school_2) { create(:school) }

  it 'should continue processing if batch fails for a single school' do
    expect {
      ContentBatchJob.perform_now
    }.to change(Delayed::Job.where(queue: 'school_content_batches'), :count).by(2)
  end

  it 'should regenerate using latest benchmark' do
    benchmark_result_generation_run_1 = BenchmarkResultGenerationRun.create!
    benchmark_result_generation_run_2 = BenchmarkResultGenerationRun.create!
    expect {
      ContentBatchJob.perform_now
    }.not_to change(BenchmarkResultGenerationRun, :count)
  end

  context 'when school has a target' do
    let!(:school_target) { create(:school_target, school: school_1) }
    it 'should end up updated' do
      ContentBatchJob.perform_now
      school_target.reload
      expect(school_target.report_last_generated).to_not be_nil
    end
  end
end

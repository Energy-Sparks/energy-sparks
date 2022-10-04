class ContentBatchJob < ApplicationJob
  self.queue_adapter = :good_job
  queue_as :school_content_batches

  def perform(schools: School.process_data, regenerate: false)
    Rails.cache.clear
    benchmark_result_generation_run = if regenerate
                                        BenchmarkResultGenerationRun.create!
                                      else
                                        BenchmarkResultGenerationRun.latest
                                      end

    schools.each do |school|
      SchoolContentBatchJob.perform_later(
        school: school,
        benchmark_result_generation_run: benchmark_result_generation_run
      )
    end
  end
end

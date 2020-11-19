class SchoolBatchRunJob < ApplicationJob
  queue_as :default

  def perform(school_batch_run)
    school_batch_run.update(status: :running)

    school = school_batch_run.school

    total_amr_readings_before = AmrValidatedReading.count

    school_batch_run.log('Validating and persisting...')

    Amr::ValidateAndPersistReadingsService.new(school).perform

    school_batch_run.log('Clearing cache...')

    AggregateSchoolService.new(school).invalidate_cache

    total_amr_readings_after = AmrValidatedReading.count

    msg = "Total AMR Readings after: #{total_amr_readings_after} - inserted: #{total_amr_readings_after - total_amr_readings_before}"

    school_batch_run.log(msg)
    school_batch_run.log('Generating...')

    ContentBatch.new([school]).generate

    school_batch_run.log('Finished')
    school_batch_run.update(status: :done)
  end
end

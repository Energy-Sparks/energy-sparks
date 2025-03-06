class ManualDataLoadRunJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(manual_data_load_run)
    load(manual_data_load_run.amr_uploaded_reading.amr_data_feed_config,
         manual_data_load_run.amr_uploaded_reading,
         manual_data_load_run)
  end

  def load(amr_data_feed_config, amr_uploaded_reading, manual_data_load_run)
    manual_data_load_run.update!(status: :running)
    begin
      manual_data_load_run.info("Started import of #{amr_uploaded_reading.file_name}")

      amr_data_feed_import_log = create_import_log(amr_data_feed_config, amr_uploaded_reading.file_name)

      Amr::ProcessAmrReadingData.new(amr_data_feed_config, amr_data_feed_import_log).perform(amr_uploaded_reading.valid_readings, amr_uploaded_reading.warnings)

      manual_data_load_run.info('Finished processing')
      amr_uploaded_reading.update!(imported: true)
      manual_data_load_run.info("Inserted: #{amr_data_feed_import_log.records_imported}")
      manual_data_load_run.info("Updated: #{amr_data_feed_import_log.records_updated}")
      manual_data_load_run.info('SUCCESS')
      status = :done
    rescue => e
      Rollbar.error(e, job: :manual_data_load_run, id: manual_data_load_run.id, filename: amr_uploaded_reading.file_name)
      manual_data_load_run.error("Error: #{e.message}")
      manual_data_load_run.error('FAILED')
      status = :failed
    end
    manual_data_load_run.update!(status: status)
  end

  private

  def create_import_log(amr_data_feed_config, file_name)
    AmrDataFeedImportLog.create(
      amr_data_feed_config: amr_data_feed_config,
      file_name: file_name,
      import_time: DateTime.now.utc
    )
  end
end

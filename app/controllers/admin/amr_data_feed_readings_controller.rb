module Admin
  class AmrDataFeedReadingsController < AdminController
    def create
      amr_upload_reading = AmrUploadedReading.find(params[:amr_uploaded_reading_id])

      amr_data_feed_import_log = AmrDataFeedImportLog.create(
        amr_data_feed_config_id: amr_upload_reading.amr_data_feed_config_id,
        file_name: amr_upload_reading.file_name,
        import_time: DateTime.now.utc
        )

      Amr::DataFeedUpserter.new(amr_upload_reading.reading_data, amr_data_feed_import_log).perform

      amr_upload_reading.update!(imported: true)

      redirect_to admin_amr_data_feed_config_path(amr_upload_reading.amr_data_feed_config_id), notice: "We have inserted #{amr_data_feed_import_log.records_imported} records and updated #{amr_data_feed_import_log.records_updated} records"
    end
  end
end

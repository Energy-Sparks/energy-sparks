module Admin
  class AmrUploadedReadingsController < AdminController
    def show
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @amr_uploaded_reading = AmrUploadedReading.find(params[:id])

      begin
        first_record = @amr_uploaded_reading.reading_data.first
        first_reading_date_string = first_record["reading_date"]
        Date.parse(first_reading_date_string)
      rescue ArgumentError
        @error = "We had a problem parsing the first date, which was #{first_reading_date_string}, here is the first row: #{first_record}"
      end
    end

    def new
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @amr_uploaded_reading = AmrUploadedReading.new(amr_data_feed_config: @amr_data_feed_config)
    end

    def create
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
      @csv_file = params[:amr_uploaded_reading][:csv_file]

      reading_data = Amr::CsvToReadingsHash.new(@amr_data_feed_config, @csv_file.tempfile).perform

      amr_uploaded_reading = AmrUploadedReading.new(
        amr_data_feed_config: @amr_data_feed_config,
        file_name: @csv_file.original_filename,
        reading_data: reading_data
        )

      if amr_uploaded_reading.save!
        redirect_to admin_amr_data_feed_config_amr_uploaded_reading_path(@amr_data_feed_config, amr_uploaded_reading)
      else
        render :new
      end
    end
  end
end

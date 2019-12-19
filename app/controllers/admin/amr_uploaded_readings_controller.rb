module Admin
  class AmrUploadedReadingsController < AdminController
    before_action :set_amr_data_feed_config

    def show
      @amr_uploaded_reading = AmrUploadedReading.find(params[:id])
    end

    def new
      @amr_uploaded_reading = AmrUploadedReading.new(amr_data_feed_config: @amr_data_feed_config)
    end

    def create
      @csv_file = params[:amr_uploaded_reading][:csv_file]

      @amr_reading_data = Amr::CsvToAmrReadingData.new(@amr_data_feed_config, @csv_file.tempfile).perform

      @amr_uploaded_reading = AmrUploadedReading.new(
        amr_data_feed_config: @amr_data_feed_config,
        file_name: @csv_file.original_filename,
        reading_data: @amr_reading_data.reading_data
      )

      if @amr_reading_data.valid? && @amr_uploaded_reading.valid?
        @amr_uploaded_reading.save!
        redirect_to admin_amr_data_feed_config_amr_uploaded_reading_path(@amr_data_feed_config, @amr_uploaded_reading)
      else
        @errors = @amr_reading_data.errors.messages[:reading_data].join(', ')
        render :new
      end
    end

    private

    def set_amr_data_feed_config
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
    end
  end
end

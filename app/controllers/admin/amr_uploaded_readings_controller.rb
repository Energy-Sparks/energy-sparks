module Admin
  class AmrUploadedReadingsController < AdminController
    before_action :set_amr_data_feed_config

    def show
      @amr_uploaded_reading = AmrUploadedReading.find(params[:id])

      set_valid_readings_and_warnings
    end

    def new
      @amr_uploaded_reading = AmrUploadedReading.new(amr_data_feed_config: @amr_data_feed_config)
    end

    def create
      @data_file = params[:amr_uploaded_reading][:data_file]

      @amr_reading_data = Amr::DataFileToAmrReadingData.new(@amr_data_feed_config, @data_file.tempfile).perform
      @amr_uploaded_reading = AmrUploadedReading.new(
        amr_data_feed_config: @amr_data_feed_config,
        file_name: @data_file.original_filename,
        reading_data: @amr_reading_data.reading_data
      )

      if @amr_reading_data.valid? && @amr_uploaded_reading.valid?
        @amr_uploaded_reading.save!
        redirect_to admin_amr_data_feed_config_amr_uploaded_reading_path(@amr_data_feed_config, @amr_uploaded_reading)
      else
        @errors = @amr_reading_data.errors.messages[:reading_data].join(', ')
        set_valid_readings_and_warnings
        render :new
      end
    rescue => e
      puts e
      puts e.backtrace
      Rollbar.error(e)
      @errors = ["Error: #{e.message}"]
      @amr_uploaded_reading = AmrUploadedReading.new(amr_data_feed_config: @amr_data_feed_config)
      render :new
    end

    private

    def set_valid_readings_and_warnings
      @valid_reading_data = @amr_uploaded_reading.valid_readings.first(10)
      @warnings = @amr_uploaded_reading.warnings.first(10)
    end

    def set_amr_data_feed_config
      @amr_data_feed_config = AmrDataFeedConfig.find(params[:amr_data_feed_config_id])
    end
  end
end

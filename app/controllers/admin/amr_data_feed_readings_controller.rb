module Admin
  class AmrDataFeedReadingsController < AdminController
    skip_before_action :verify_authenticity_token

    def preview
      @config = AmrDataFeedConfig.find(params[:preview][:amr_data_feed_config_id])

      readings_hash = Amr::CsvToReadingsHash.new(@config, params[:preview][:csv_file].tempfile).perform

      send_data readings_hash.to_json
      # CSV.parse(params[:preview][:csv_file].tempfile)
    end
  end
end

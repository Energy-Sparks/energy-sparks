module Admin
  class AmrDataFeedConfigsController < AdminController
    def index
      @configurations = AmrDataFeedConfig.order(:description)
    end

    def show
      @configuration = AmrDataFeedConfig.find(params[:id])
    end

    def edit
      @configuration = AmrDataFeedConfig.find(params[:id])
    end

    def update
      @configuration = AmrDataFeedConfig.find(params[:id])
      if @configuration.update!(amr_data_feed_config_params)
        redirect_to admin_amr_data_feed_config_path(@configuration)
      else
        render :edit
      end
    end

    private

    def amr_data_feed_config_params
      params.require(:amr_data_feed_config).permit(:import_warning_days, :missing_readings_limit)
    end
  end
end

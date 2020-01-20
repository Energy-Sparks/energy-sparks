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
      if @configuration.update!(import_warning_days: params[:amr_data_feed_config][:import_warning_days])
        redirect_to admin_amr_data_feed_config_path(@configuration)
      else
        render :edit
      end
    end
  end
end

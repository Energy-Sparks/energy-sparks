module Admin
  class AmrDataFeedConfigsController < AdminController
    def index
      @configurations = AmrDataFeedConfig.all.order(:description)
    end

    def show
      @configuration = AmrDataFeedConfig.find(params[:id])
    end
  end
end

module Admin
  class AlertTypesController < AdminController
    def index
      @alert_types = AlertType.order(:title)
    end

    def show
      @alert_type = AlertType.find(params[:id])
    end
  end
end

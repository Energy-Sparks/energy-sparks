module Admin
  class AlertTypesController < AdminController
    load_and_authorize_resource

    def index
      @alert_types = AlertType.order(:title)
    end

    def show
    end

    def edit
    end

    def update
      if @alert_type.update(alert_type_params)
        redirect_to admin_alert_type_path(@alert_type), notice: 'Alert type updated'
      else
        render :edit
      end
    end

  private

    def alert_type_params
      params.require(:alert_type).permit(:title, :description, :frequency)
    end
  end
end

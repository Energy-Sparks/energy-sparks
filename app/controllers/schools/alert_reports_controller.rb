class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @latest_alerts = @school.alerts.latest.sort_by(&:created_at).reverse
    @alerts = @school.alerts - @school.alerts.latest
  end
end

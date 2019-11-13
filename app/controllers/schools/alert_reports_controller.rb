class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @latest_alerts = @school.latest_alerts_without_exclusions
  end
end

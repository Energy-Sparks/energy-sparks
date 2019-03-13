class Schools::AlertReportsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @termly_alerts = @school.alerts.termly.order(created_at: :desc)
    @weekly_alerts = @school.alerts.weekly.order(created_at: :desc)
    @holiday_alerts = @school.alerts.before_each_holiday.order(created_at: :desc)
  end
end

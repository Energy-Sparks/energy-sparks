class Schools::AlertsController < ApplicationController
  load_and_authorize_resource :school

  def index
    authorize! :read, AlertType

    @termly_alerts = latest_alerts_for(@school.alerts.termly)
    @weekly_alerts = latest_alerts_for(@school.alerts.weekly)
  end

private

  def latest_alerts_for(alerts)
    alerts.order(created_at: :desc).group_by { |alert| [alert.alert_type_id] }.values.map(&:first)
  end
end

module Schools
  class AlertsController < ApplicationController
    load_and_authorize_resource :school

    layout 'dashboards'

    def show
      @alert = Alert.find(params[:id])
      authorize! :read, @alert
    end
  end
end

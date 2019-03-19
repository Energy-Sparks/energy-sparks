module Schools
  class FindOutMoreController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource :alert

    skip_before_action :authenticate_user!

    def show
      @activity_types = @alert.alert_type.activity_types.limit(3)
    end
  end
end

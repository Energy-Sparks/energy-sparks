module Schools
  class FindOutMoreController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource

    skip_before_action :authenticate_user!

    def show
      @activity_types = @find_out_more.alert.alert_type.activity_types.limit(3)
      @alert = @find_out_more.alert
      @content = @find_out_more.content_version
    end
  end
end

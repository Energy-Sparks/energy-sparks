module Schools
  class PrivateController < ApplicationController
    load_resource :school

    skip_before_action :authenticate_user!

    def show
      if @school.public? || can?(:show, @school)
        redirect_to school_path(@school)
      else
        render :show
      end
    end
  end
end

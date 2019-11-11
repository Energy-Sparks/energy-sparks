module Schools
  class InactiveController < ApplicationController
    load_resource :school

    def show
      if @school.visible?
        redirect_to school_path(@school)
      else
        render :show
      end
    end
  end
end

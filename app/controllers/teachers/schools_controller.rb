module Teachers
  class SchoolsController < ApplicationController
    load_resource

    #retained to avoid any old urls breaking
    def show
      redirect_to pupils_school_path(@school), status: :found
    end
  end
end

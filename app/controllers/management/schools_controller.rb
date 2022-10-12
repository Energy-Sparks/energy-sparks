module Management
  class SchoolsController < ApplicationController
    load_and_authorize_resource

    def show
      redirect_to school_path(@school), status: :moved_permanently
    end
  end
end

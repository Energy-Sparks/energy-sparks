module Schools
  class DownloadsController < ApplicationController
    load_and_authorize_resource :school
    before_action :authorized?

    def index
    end

    private

    def authorized?
      unless can?(:download_school_data, @school)
        flash[:error] = "You are not authorized to view that page."
        redirect_to root_path
      end
    end
  end
end

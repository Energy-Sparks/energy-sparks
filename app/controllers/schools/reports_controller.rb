module Schools
  class ReportsController < ApplicationController
    load_and_authorize_resource :school
    def index
      authorize! :view_content_reports, @school
      layout = Flipper.enabled?(:new_manage_school_pages, current_user) ? 'dashboards' : 'application'
      render :index, layout: layout
    end
  end
end

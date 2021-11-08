module Schools
  class ReportsController < ApplicationController
    load_and_authorize_resource :school
    def index
      authorize! :view_content_reports, @school
    end
  end
end

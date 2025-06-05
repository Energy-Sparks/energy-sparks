module Schools
  class EquivalenceReportsController < ApplicationController
    load_and_authorize_resource :school

    layout 'dashboards'

    def index
      authorize! :view_content_reports, @school
      @equivalences = @school.equivalences.order(created_at: :desc)
    end

    def show
      authorize! :view_content_reports, @school
      @equivalence = @school.equivalences.find(params[:id])
    end
  end
end

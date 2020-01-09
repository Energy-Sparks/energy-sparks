module Schools
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    include SchoolAggregation
    include AnalysisPages

    before_action :check_aggregated_school_in_cache, only: :show

    def index
      setup_analysis_pages(@school.latest_analysis_pages)
    end

    def show
      @page = @school.analysis_pages.find(params[:id])
      framework_adapter = Alerts::FrameworkAdapter.new(
        alert_type: @page.alert.alert_type,
        school: @school,
        analysis_date: @page.alert.run_on,
        aggregate_school: aggregate_school
      )
      @content = framework_adapter.content
      @title = page_title(@content, @school)
    rescue ActiveRecord::RecordNotFound
      if /\d/.match?(params[:id])
        # new-style numeric analysis page that doesn't exist, re-raise to 404
        raise
      else
        # old-style analysis tab name, redirect back to main page
        redirect_to school_analysis_index_path(@school), status: :moved_permanently
      end
    end

  private

    def page_title(content, school)
      title = content.find { |element| element[:type] == :title }
      if title
        title[:content]
      else
        "#{school.name} analysis"
      end
    end
  end
end

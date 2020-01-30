module Schools
  class AnalysisController < ApplicationController
    load_and_authorize_resource :school
    skip_before_action :authenticate_user!

    include SchoolAggregation
    include AnalysisPages
    include UserTypeSpecific

    before_action :check_aggregated_school_in_cache, only: :show
    before_action :load_page_and_alert_type, only: :show
    before_action :check_authorisation, only: :show

    def index
      setup_analysis_pages(@school.latest_analysis_pages)
    end

    def show
      framework_adapter = Alerts::FrameworkAdapter.new(
        alert_type: @alert_type,
        school: @school,
        analysis_date: @page.alert.run_on,
        aggregate_school: aggregate_school
      )
      @content = framework_adapter.content(user_type_hash)
      @structured_content = framework_adapter.structured_content if framework_adapter.has_structured_content?

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

    def load_page_and_alert_type
      @page = @school.analysis_pages.find(params[:id])
      @alert_type = @page.alert.alert_type
    end

    def check_authorisation
      if @alert_type.user_restricted && cannot?(:read_restricted_analysis, @school)
        redirect_to school_analysis_index_path(@school), notice: 'Only a user for this school can access this content'
      end
    end

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

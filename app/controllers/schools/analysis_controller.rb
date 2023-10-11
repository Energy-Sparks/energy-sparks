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
      I18n.with_locale(:en) do
        @content = framework_adapter.content(user_type_hash)
        @structured_content = framework_adapter.structured_content if framework_adapter.has_structured_content?
      end
      @title = page_title(@content, @school)
    rescue ActiveRecord::RecordNotFound
      if /\d/.match?(params[:id])
        # new-style numeric analysis page that doesn't exist, re-raise to 404
        raise
      else
        # old-style analysis tab name, redirect back to main page
        redirect_to school_analysis_index_path(@school), status: :moved_permanently
      end
    rescue StandardError => e
      log_error_if_current_page(e, @school, @page)
      flash[:error] = "Analysis page raised error: #{e.message}"
    end

    private

    def log_error_if_current_page(error, school, page)
      if school.latest_analysis_pages.include?(page)
        Rails.logger.error("#{error.message} for #{school.name}")
        Rollbar.error(error, school_id: school.id, school_name: school.name)
      end
    end

    def load_page_and_alert_type
      @page = @school.analysis_pages.find(params[:id])
      @alert_type = @page.alert.alert_type
    end

    def check_authorisation
      if @alert_type.user_restricted && cannot?(:read_restricted_analysis, @school)
        redirect_to school_analysis_index_path(@school), notice: 'Only an admin or staff user for this school can access this content'
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

class AnalysisPageFinderController < ApplicationController
  skip_before_action :authenticate_user!
  include AnalysisPages
  include ApplicationHelper
  include AdvicePageHelper

  def show
    urn = params[:urn]
    analysis_class = params[:analysis_class]

    school = School.find_by!(urn: urn)

    if replace_analysis_pages?
      alert_type = find_advice_page_of_class(analysis_class)
      if alert_type.advice_page.present?
        redirect_to advice_page_path(school, alert_type.advice_page)
      else
        redirect_to school_advice_path(school)
      end
    else
      analysis_page = find_analysis_page_of_class(school, analysis_class)
      if analysis_page
        redirect_to school_analysis_path(school.slug, analysis_page.id)
      else
        redirect_back fallback_location: compare_index_path, notice: "We couldn't take you to the correct location, sorry."
      end
    end
  end
end

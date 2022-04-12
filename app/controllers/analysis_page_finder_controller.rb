class AnalysisPageFinderController < ApplicationController
  skip_before_action :authenticate_user!
  include AnalysisPages

  def show
    school_id = params[:school_id]
    analysis_class = params[:analysis_class]

    school = School.find(school_id)
    analysis_page = find_analysis_page_of_class(school, analysis_class)

    if analysis_page
      redirect_to school_analysis_path(school.slug, analysis_page.id)
    else
      redirect_back fallback_location: benchmarks_path, notice: "We couldn't take you to the correct location, sorry."
    end
  end
end

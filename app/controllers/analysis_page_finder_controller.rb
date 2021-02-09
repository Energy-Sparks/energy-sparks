class AnalysisPageFinderController < ApplicationController
  skip_before_action :authenticate_user!
  include AnalysisPages

  def show
    urn = params[:urn]
    analysis_class = params[:analysis_class]

    school = School.find_by!(urn: urn)
    alert_type = AlertType.where("lower(class_name) = ?", analysis_class.downcase).first!

    if school.latest_analysis_pages.any?
      analysis_page = school.latest_analysis_pages.includes(:alert).detect { |page| page.alert.alert_type_id == alert_type.id }
    end

    if analysis_page
      redirect_to school_analysis_path(school.slug, analysis_page.id)
    else
      redirect_back fallback_location: benchmarks_path, notice: "We couldn't take you to the correct location, sorry."
    end
  end
end

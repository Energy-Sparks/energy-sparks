class AnalysisPageFinderController < ApplicationController
  skip_before_action :authenticate_user!
  include ApplicationHelper
  include AdvicePageHelper

  def show
    urn = params[:urn]
    analysis_class = params[:analysis_class]

    school = School.find_by!(urn: urn)

    alert_type = find_advice_page_of_class(analysis_class)
    if alert_type && alert_type.advice_page.present?
      redirect_to advice_page_path(school, alert_type.advice_page), status: :moved_permanently
    else
      redirect_to school_advice_path(school), status: :moved_permanently
    end
  end

  private

  def find_advice_page_of_class(analysis_class)
    AlertType.where('lower(class_name) = ?', analysis_class.downcase).first
  end
end

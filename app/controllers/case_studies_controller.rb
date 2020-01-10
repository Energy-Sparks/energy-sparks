class CaseStudiesController < ApplicationController
  skip_before_action :authenticate_user!
  def index
    @case_studies = CaseStudy.order(position: :asc)
  end
end

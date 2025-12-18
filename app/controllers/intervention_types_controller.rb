class InterventionTypesController < ApplicationController
  include Pagy::Method
  load_and_authorize_resource
  before_action :handle_head_request, only: [:show]
  skip_before_action :authenticate_user!, only: [:search, :show, :for_school]

  def search
    if params[:query]
      intervention_types = InterventionTypeSearchService.search(params[:query], I18n.locale)
      @pagy, @intervention_types = pagy(intervention_types)
    else
      @intervention_types = []
    end
  end

  def show
    if current_user_school
      @interventions = current_user_school.observations.includes(:intervention_type).intervention.where(intervention_type: @intervention_type).visible.by_date
    end
    @can_be_completed_for_schools = current_user.schools(current_ability:) if current_user
  end

  def for_school
    school = School.find(params[:school_id])
    redirect_to new_school_intervention_path(school, intervention_type_id: @intervention_type.id)
  end
end

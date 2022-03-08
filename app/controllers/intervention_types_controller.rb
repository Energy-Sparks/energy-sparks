class InterventionTypesController < ApplicationController
  include Pagy::Backend
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:search, :show]

  def search
    if params[:query]
      intervention_types = InterventionTypeSearchService.search(params[:query])
      @pagy, @intervention_types = pagy(intervention_types)
    else
      @intervention_types = []
    end
  end

  def show
    if current_user_school
      @interventions = current_user_school.observations.includes(:intervention_type).intervention.where(intervention_type: @intervention_type).visible.by_date
    end
  end
end

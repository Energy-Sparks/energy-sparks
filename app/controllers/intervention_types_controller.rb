class InterventionTypesController < ApplicationController
  load_and_authorize_resource

  skip_before_action :authenticate_user!, only: [:index, :show]

  def index
  end

  def show
    if current_user_school
      @interventions = current_user_school.observations.includes(:intervention_type).intervention.where(intervention_type: @intervention_type).visible.by_date
    end
  end
end

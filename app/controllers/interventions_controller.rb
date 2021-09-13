class InterventionsController < ApplicationController
  def new
    @intervention_type = InterventionType.find(params[:intervention_type_id])
    @intervention_type_group = @intervention_type.intervention_type_group
    @observation = current_user.school.observations.new(intervention_type_id: @intervention_type.id)
  end

  def create
    @observation = current_user.school.observations.new(observation_params)
    if InterventionCreator.new(@observation).process
      redirect_to school_interventions_path(current_user_school)
    else
      render :new
    end
  end

  def edit
    @observation = Observation.find(params[:id])
    @intervention_type = @observation.intervention_type
  end

  def update
    @observation = Observation.find(params[:id])
    if @observation.update(observation_params)
      redirect_to school_interventions_path(current_user_school)
    else
      render :edit
    end
  end

  def destroy
    @observation = Observation.find(params[:id])
    ObservationRemoval.new(@observation).process
    redirect_back fallback_location: school_interventions_path(current_user_school)
  end

  private

  def observation_params
    params.require(:observation).permit(:description, :at, :intervention_type_id)
  end
end

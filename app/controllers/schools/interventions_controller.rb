module Schools
  class InterventionsController < ApplicationController
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    before_action :load_intervention_type_groups, except: [:index, :destroy]

    def index
      @interventions = @observations.intervention.order('at ASC')
    end

    def new
    end

    def create
      @observation.observation_type = :intervention
      if @observation.save
        redirect_to school_interventions_path(@school)
      else
        render :new
      end
    end

    def edit
    end

    def update
      if @observation.update(observation_params)
        redirect_to school_interventions_path(@school)
      else
        render :edit
      end
    end

    def destroy
      @observation.destroy!
      redirect_to school_interventions_path(@school)
    end

  private

    def load_intervention_type_groups
      @intervention_type_groups = InterventionTypeGroup.includes(:intervention_types).references(:intervention_types).order('intervention_type_groups.title ASC, intervention_types.title ASC')
    end

    def observation_params
      params.require(:observation).permit(:description, :at, :intervention_type_id)
    end
  end
end

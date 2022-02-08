module Schools
  class InterventionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    before_action :load_intervention_types, except: [:index, :destroy]

    def index
      @interventions = @observations.intervention.visible.order('at DESC')
    end

    def new
    end

    def create
      if InterventionCreator.new(@observation).process
        redirect_to completed_school_intervention_path(@school, @observation)
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
      ObservationRemoval.new(@observation).process
      redirect_back fallback_location: school_interventions_path(@school)
    end

    def show
    end

    def completed
      if current_user_school
        @suggested_actions = load_suggested_actions(current_user_school)
        @completed_actions = load_completed_actions(current_user_school)
      end
    end

  private

    def load_intervention_types
      @intervention_type_group = if @observation.intervention_type
                                   @observation.intervention_type.intervention_type_group
                                 else
                                   InterventionTypeGroup.find(params[:intervention_type_group_id])
                                 end
      @intervention_types = @intervention_type_group.intervention_types.display_order
    end

    def observation_params
      params.require(:observation).permit(:description, :at, :intervention_type_id)
    end

    def load_suggested_actions(school)
      Interventions::SuggestAction.new(school).suggest(4)
    end

    def load_completed_actions(school)
      school.observations_in_academic_year(Time.zone.today)
    end
  end
end

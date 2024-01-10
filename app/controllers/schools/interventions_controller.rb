module Schools
  class InterventionsController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index, :show]
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    def index
      @interventions = @observations.intervention.visible.order('at DESC')
    end

    def new
      @intervention_type = InterventionType.find(params[:intervention_type_id])
      @observation = @school.observations.new(intervention_type_id: @intervention_type.id)
      authorize! :create, @observation
    end

    def create
      @observation = @school.observations.new(observation_params.merge(observation_type: :intervention))
      authorize! :create, @observation
      if @observation.save
        redirect_to completed_school_intervention_path(@school, @observation)
      else
        @intervention_type = @observation.intervention_type
        render :new
      end
    end

    def edit
      authorize! :edit, @observation
      @intervention_type = @observation.intervention_type
    end

    def update
      authorize! :update, @observation
      if @observation.update(observation_params)
        redirect_to school_interventions_path(@school)
      else
        render :edit
      end
    end

    def destroy
      authorize! :delete, @observation
      ObservationRemoval.new(@observation).process
      redirect_back fallback_location: school_interventions_path(@school)
    end

    def show
    end

    def completed
      return if EnergySparks::FeatureFlags.active?(:activities_2024)

      @suggested_actions = load_suggested_actions(@school)
      @completed_actions = load_completed_actions(@school)
    end

  private

    def observation_params
      params.require(:observation).permit(:description, :at, :intervention_type_id, :involved_pupils, :pupil_count)
    end

    def load_suggested_actions(school)
      Interventions::SuggestAction.new(school).suggest(4)
    end

    def load_completed_actions(school)
      school.observations_in_academic_year(Time.zone.today)
    end
  end
end

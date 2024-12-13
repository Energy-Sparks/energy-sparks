# frozen_string_literal: true

module Schools
  class InterventionsController < ApplicationController
    skip_before_action :authenticate_user!, only: %i[index show]
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false

    def index
      @interventions = @observations.intervention.visible.order('at DESC')
    end

    def show
      if @observation.observation_type == 'activity'
        redirect_to school_activity_path(@school, @observation.activity_id), status: :moved_permanently
      else
        render :show
      end
    end

    def new
      @intervention_type = InterventionType.find(params[:intervention_type_id])
      @observation = @school.observations.new(intervention_type_id: @intervention_type.id)
      authorize! :create, @observation
    end

    def edit
      authorize! :edit, @observation
      @intervention_type = @observation.intervention_type
    end

    def create
      if Flipper.enabled?(:todos, current_user)
        @observation = @school.observations.intervention.new(observation_params)

        authorize! :create, @observation
        if Tasks::Recorder.new(@observation, current_user).process
          redirect_to completed_school_intervention_path(@school, @observation)
        else
          @intervention_type = @observation.intervention_type
          render :new
        end
      else
        @observation = @school.observations.new(observation_params.merge(observation_type: :intervention,
                                                                         created_by: current_user))
        authorize! :create, @observation
        if @observation.save
          redirect_to completed_school_intervention_path(@school, @observation)
        else
          @intervention_type = @observation.intervention_type
          render :new
        end
      end
    end

    def update
      authorize! :update, @observation
      if @observation.update(observation_params.merge(updated_by: current_user))
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

    def completed; end

    private

    def observation_params
      params.require(:observation).permit(:description, :at, :intervention_type_id, :involved_pupils, :pupil_count)
    end
  end
end

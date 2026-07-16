# frozen_string_literal: true

module Schools
  class InterventionsController < ApplicationController
    before_action :enable_bootstrap5, except: %i[show]
    skip_before_action :authenticate_user!, only: %i[show]
    load_resource :school
    load_and_authorize_resource :observation, through: :school, parent: false
    before_action :set_breadcrumbs, only: %i[new create edit update]

    def show
      if @observation.observation_type == 'activity'
        redirect_to school_activity_path(@school, @observation.activity_id), status: :moved_permanently
      else
        render :show
      end
    end

    def new
      @observation = @school.observations.intervention.new(intervention_type: intervention_type)
      authorize! :create, @observation
    end

    def edit; end

    def create
      @observation = @school.observations.intervention.new(observation_params)

      authorize! :create, @observation
      if Tasks::Recorder.new(@observation, current_user).process
        redirect_to completed_school_intervention_path(@school, @observation)
      else
        render :new
      end
    end

    def update
      if @observation.update(observation_params.merge(updated_by: current_user))
        redirect_to school_interventions_path(@school), notice: I18n.t('interventions.notices.updated')
      else
        render :edit
      end
    end

    def destroy
      ObservationRemoval.new(@observation).process
      redirect_to school_interventions_path(@school), notice: I18n.t('interventions.notices.removed')
    end

    def completed; end

    private

    def observation_params
      params.require(:observation).permit(:description, :at, :intervention_type_id, :involved_pupils, :pupil_count)
    end

    def intervention_type
      @intervention_type ||=
        if params[:intervention_type_id].present?
          InterventionType.find(params[:intervention_type_id])
        elsif @observation.present?
          @observation.intervention_type
        end
    end

    def set_breadcrumbs
      return unless intervention_type

      intervention_type.category
      @breadcrumbs = [
        { name: t('common.labels.adult_actions'), href: intervention_type_groups_path },
        { name: intervention_type.name, href: intervention_type_path(intervention_type) },
        { name: t('interventions.form.record_action') }
      ].compact
    end
  end
end

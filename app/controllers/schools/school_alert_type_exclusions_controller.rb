module Schools
  class SchoolAlertTypeExclusionsController < ApplicationController
    load_and_authorize_resource :school
    load_and_authorize_resource through: :school

    layout 'dashboards'

    def index
      authorize! :manage_exclusions, @school
      exclusions_and_types
    end

    def create
      @school_alert_type_exclusion.created_by = current_user
      if @school_alert_type_exclusion.save
        redirect_back fallback_location: school_school_alert_type_exclusions_path(@school), notice: 'Exclusion created'
      else
        exclusions_and_types
        flash[:error] = @school_alert_type_exclusion.errors.full_messages.join(', ')
        render :index
      end
    end

    def destroy
      @school_alert_type_exclusion.destroy
      redirect_to school_school_alert_type_exclusions_path(@school), notice: 'Exclusion deleted'
    end

    private

    def exclusions_and_types
      @exclusions = @school.school_alert_type_exclusions.includes(:alert_type).order(:alert_type_id)
      @alert_types = AlertType.enabled.where.not(id: @exclusions.map(&:alert_type)).order(:title)
    end

    def school_alert_type_exclusion_params
      params.require(:school_alert_type_exclusion).permit(:alert_type_id, :reason)
    end
  end
end

module Schools
  class AuditsController < ApplicationController
    load_resource :school
    load_and_authorize_resource through: :school

    def index
      @audits = @audits.by_title
    end

    def show
    end

    def edit
    end

    def create
      if @audit.save
        redirect_to school_audits_path(@school), notice: 'Audit created'
      else
        render :new
      end
    end

    def update
      if @audit.update(audit_params)
        redirect_to school_audits_path(@school), notice: 'Audit updated'
      else
        render :edit
      end
    end

    def destroy
      @audit.destroy
      redirect_to school_audits_path(@school), notice: "Audit was successfully deleted."
    end

  private

    def audit_params
      params.require(:audit).permit(:school_id, :title, :description, :published, audit_activity_types_attributes: audit_activity_types_attributes, audit_intervention_types_attributes: audit_intervention_types_attributes)
    end

    def audit_activity_types_attributes
      [:id, :activity_type_id, :activity_type, :notes, :_destroy]
    end

    def audit_intervention_types_attributes
      [:id, :intervention_type_id, :intervention_type, :notes, :_destroy]
    end
  end
end

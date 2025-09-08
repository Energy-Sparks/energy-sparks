module Schools
  class AuditsController < ApplicationController
    load_resource :school
    load_and_authorize_resource through: :school
    before_action :set_breadcrumbs

    def index
      if can?(:manage, Audit)
        @audits = @audits.by_date
      else
        @audits = @audits.published.by_date
        redirect_to energy_audits_path if @audits.none?
      end
    end

    def show
    end

    def edit
    end

    def create
      if Audits::AuditService.new(@school).process(@audit)
        redirect_to school_audit_path(@school, @audit), notice: I18n.t('schools.audits.created')
      else
        render :new
      end
    end

    def update
      if @audit.update(audit_params)
        Audits::AuditService.new(@school).update_points(@audit)
        redirect_to school_audit_path(@school, @audit), notice: I18n.t('schools.audits.updated')
      else
        render :edit
      end
    end

    def destroy
      @audit.destroy
      redirect_to school_audits_path(@school), notice: I18n.t('schools.audits.deleted')
    end

  private

    def set_breadcrumbs
      @breadcrumbs = [{ name: I18n.t('energy_audits.title') }]
    end

    def audit_params
      params.require(:audit).permit(:school_id, :title, :description, :file, :published, :involved_pupils,
          audit_activity_types_attributes: audit_activity_types_attributes, # remove when todos feature flag removed
          audit_intervention_types_attributes: audit_intervention_types_attributes, # remove when todos feature flag removed
          activity_type_todos_attributes: todos_attributes,
          intervention_type_todos_attributes: todos_attributes)
    end

    def audit_activity_types_attributes
      [:id, :activity_type_id, :activity_type, :notes, :_destroy]
    end

    def audit_intervention_types_attributes
      [:id, :intervention_type_id, :intervention_type, :notes, :_destroy]
    end

    def todos_attributes
      [:id, :task_id, :task, :task_type, :position, :notes, :_destroy]
    end
  end
end

module Admin
  module AlertTypes
    class SchoolAlertTypeExclusionsController < AdminController
      load_and_authorize_resource :school_alert_type_exclusion
      load_and_authorize_resource :alert_type

      def index
        @exclusions = @alert_type.school_alert_type_exclusions.includes(:school).order('schools.name')
      end

      def new
        @school_groups = SchoolGroup.main_groups.order(name: :asc)
        @existing_exclusions = @alert_type.school_alert_type_exclusions.pluck(:school_id, :reason).to_h
      end

      def create
        school_ids = params[:school_ids]
        reasons = params[:school_reasons]

        SchoolAlertTypeExclusion.where(alert_type: @alert_type).delete_all

        school_ids.each do |school_id|
          SchoolAlertTypeExclusion.create(alert_type: @alert_type, school_id: school_id, reason: reasons[school_id])
        end
        redirect_to admin_alert_type_school_alert_type_exclusions_path(@alert_type)
      end

      def destroy
        @school_alert_type_exclusion.delete
        redirect_to admin_alert_type_school_alert_type_exclusions_path(@alert_type)
      end
    end
  end
end

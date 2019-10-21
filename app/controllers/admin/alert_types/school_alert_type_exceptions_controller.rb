module Admin
  module AlertTypes
    class SchoolAlertTypeExceptionsController < AdminController
      load_and_authorize_resource :school_alert_type_exception
      load_and_authorize_resource :alert_type

      def index
        @exceptions = SchoolAlertTypeException.where(alert_type: @alert_type)
      end

      def new
        @school_groups = SchoolGroup.all.order(name: :asc)
        @existing_exceptions = @alert_type.school_alert_type_exceptions.pluck(:school_id, :reason).to_h
      end

      def create
        school_ids = params[:school_ids]
        reasons = params[:school_reasons]

        SchoolAlertTypeException.where(alert_type: @alert_type).delete_all

        school_ids.each_with_index do |school_id, index|
          SchoolAlertTypeException.create(alert_type: @alert_type, school_id: school_id, reason: reasons[index])
        end
        redirect_to admin_alert_type_school_alert_type_exceptions_path(@alert_type)
      end

      def destroy
        @school_alert_type_exception.delete
        redirect_to admin_alert_type_school_alert_type_exceptions_path(@alert_type)
      end
    end
  end
end

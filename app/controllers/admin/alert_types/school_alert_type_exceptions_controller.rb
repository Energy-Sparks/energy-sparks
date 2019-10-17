module Admin
  module AlertTypes
    class SchoolAlertTypeExceptionsController < AdminController
      load_and_authorize_resource :school_alert_type_exception
      load_and_authorize_resource :alert_type

      def index
        @exceptions = SchoolAlertTypeException.where(alert_type: @alert_type)
      end

      def edit_multiple
        @schools = School.all
      end
    end
  end
end

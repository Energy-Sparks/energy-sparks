module Admin
  class SchoolsController < AdminController
    load_and_authorize_resource :school

    def removal
      @school_remover = SchoolRemover.new(@school)
    end

    def deactivate_users
      service = SchoolRemover.new(@school)
      service.remove_users!
      redirect_back fallback_location: root_path, notice: "Users have been deactivated"
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def deactivate_meters
      service = SchoolRemover.new(@school)
      service.remove_meters!
      redirect_back fallback_location: root_path, notice: "Meters have been deactivated and data removed"
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def deactivate
      service = SchoolRemover.new(@school)
      service.remove_school!
      redirect_back fallback_location: root_path, notice: "School has been removed"
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end
  end
end

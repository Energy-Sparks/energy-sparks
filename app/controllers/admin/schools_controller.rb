module Admin
  class SchoolsController < AdminController
    load_and_authorize_resource :school

    def removal
      @school_remover = SchoolRemover.new(@school)
      render layout: Flipper.enabled?(:new_manage_school_pages) ? 'dashboards' : 'application'
    end

    def deactivate_users
      service = SchoolRemover.new(@school)
      service.remove_users!
      redirect_back fallback_location: root_path, notice: 'Users have been disabled'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def archive_meters
      remove_meters(archive: true)
      redirect_back fallback_location: root_path, notice: 'Meters have been archived and validated data removed'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def delete_meters
      remove_meters(archive: false)
      redirect_back fallback_location: root_path, notice: 'Meters have been deactivated and validated data removed'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def reenable
      service = SchoolRemover.new(@school)
      service.reenable_school!
      redirect_back fallback_location: root_path, notice: 'School has been re-enabled'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def archive
      remove_school(archive: true)
      redirect_back fallback_location: root_path, notice: 'School has been archived'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    def delete
      remove_school(archive: false)
      redirect_back fallback_location: root_path, notice: 'School has been removed'
    rescue => e
      redirect_back fallback_location: root_path, notice: e.message
    end

    private

    def remove_school(archive: true)
      service = SchoolRemover.new(@school, archive: archive)
      service.remove_school!
    end

    def remove_meters(archive: true)
      service = SchoolRemover.new(@school, archive: archive)
      service.remove_meters!
    end
  end
end

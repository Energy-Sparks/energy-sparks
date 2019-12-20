require 'securerandom'
module Admin
  class SchoolOnboardingsController < AdminController
    load_and_authorize_resource

    def index
      @school_groups = SchoolGroup.order(name: :asc)
      @completed_schools = @school_onboardings.order(:created_at).select(&:complete?)
    end

    def new
    end

    def create
      @school_onboarding.uuid = SecureRandom.uuid
      @school_onboarding.created_by = current_user
      if @school_onboarding.save
        redirect_to edit_admin_school_onboarding_configuration_path(@school_onboarding)
      else
        render :new
      end
    end


  private

    def school_onboarding_params
      params.require(:school_onboarding).permit(:school_name, :contact_email, :school_group_id, :notes)
    end
  end
end

require 'securerandom'
module Admin
  class SchoolOnboardingsController < AdminController
    load_and_authorize_resource find_by: :uuid

    INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME = "incomplete-onboarding-schools.csv".freeze

    def index
      @school_groups = SchoolGroup.order(name: :asc)
      @completed_schools = @school_onboardings.order(:created_at).select(&:complete?)

      respond_to do |format|
        format.html
        format.csv { send_data produce_csv, filename: INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME }
      end
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

    def edit
    end

    def update
      if @school_onboarding.update(school_onboarding_params)
        redirect_to edit_admin_school_onboarding_configuration_path(@school_onboarding)
      else
        render :edit
      end
    end

  private

    def produce_csv
      CSV.generate do |csv|
        csv << ['School name', 'School Group Name', 'Contact email', 'Notes', 'Last event']

        @school_onboardings.order(:school_group_id).select(&:incomplete?).each do |school_onboarding|
          last_event = school_onboarding.events.order(event: :desc).first.event.to_s.humanize
          csv << [school_onboarding.school_name, school_onboarding.school_group.name, school_onboarding.contact_email, school_onboarding.notes, last_event]
        end
      end
    end

    def school_onboarding_params
      params.require(:school_onboarding).permit(:school_name, :contact_email, :school_group_id, :notes)
    end
  end
end

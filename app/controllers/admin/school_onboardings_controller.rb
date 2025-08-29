require 'securerandom'
module Admin
  class SchoolOnboardingsController < AdminController
    load_and_authorize_resource find_by: :uuid

    INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME = 'incomplete-onboarding-schools.csv'.freeze

    def index
      @school_groups = SchoolGroup.order(name: :asc)
      respond_to do |format|
        format.html
        format.csv { send_data produce_csv, filename: INCOMPLETE_ONBOARDING_SCHOOLS_FILE_NAME }
      end
    end

    def new
    end

    def completed
      @completed_schools = @school_onboardings.complete.order(updated_at: :desc)
    end

    def create
      @school_onboarding.populate_default_values(current_user)
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

    def destroy
      SchoolOnboardingDeletor.new(@school_onboarding).delete!
      redirect_back fallback_location: admin_school_onboardings_path, notice: 'School onboarding was successfully destroyed.'
    rescue => e
      redirect_back fallback_location: admin_school_onboardings_path, notice: e.message
    end

    private

    def produce_csv
      CSV.generate do |csv|
        csv << ['School name', 'School Group Name', 'Contact email', 'Notes', 'Last event']

        @school_onboardings.order(:school_group_id).incomplete.each do |school_onboarding|
          last_event = school_onboarding.events.order(event: :desc).first
          last_event = last_event.event.to_s.humanize if last_event
          csv << [school_onboarding.school_name, school_onboarding.school_group&.name, school_onboarding.contact_email, school_onboarding.notes, last_event]
        end
      end
    end

    def school_onboarding_params
      params.require(:school_onboarding).permit(
        :contact_email,
        :data_sharing,
        :funder_id,
        :notes,
        :school_group_id,
        :school_name,
        :school_will_be_public,
        :urn
      )
    end
  end
end

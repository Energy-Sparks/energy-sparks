module Onboarding
  class ConsentController < BaseController
    skip_before_action :authenticate_user!
    before_action do
      redirect_if_event(:permission_given, new_onboarding_pupil_account_path(@school_onboarding))
    end

    def show
      school = @school_onboarding.school
      @consent_grant = ConsentGrant.new(consent_statement: ConsentStatement.current, name: current_user.name, job_title: current_user.role.humanize.titleize, school_name: school.name)
    end

    def create
      @consent_grant = ConsentGrant.new(school_onboarding_consent_params.merge(user: current_user, school: @school_onboarding.school))
      if @consent_grant.save
        @school_onboarding.events.create!(event: :permission_given)
        ConsentGrantMailer.with(consent_grant: @consent_grant).email_consent.deliver_now
        redirect_to new_onboarding_pupil_account_path(@school_onboarding)
      else
        render :show
      end
    end

  private

    def school_onboarding_consent_params
      params.require(:consent_grant).permit(:school_name, :name, :job_title, :consent_statement_id)
    end
  end
end

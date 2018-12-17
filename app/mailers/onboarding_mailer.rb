class OnboardingMailer < ApplicationMailer
  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    mail(to: @school_onboarding.contact_email, subject: "Set up your school on Energy Sparks")
  end

  def completion_email
    @school_onboarding = params[:school_onboarding]
    if @school_onboarding.created_by
      mail(to: @school_onboarding.created_by.email, subject: "#{@school_onboarding.school_name} has completed the onboarding process")
    end
  end
end

class OnboardingMailer < ApplicationMailer
  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    mail(to: @school_onboarding.contact_email, subject: "Set up your school on Energy Sparks")
  end
end

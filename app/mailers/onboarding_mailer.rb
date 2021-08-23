class OnboardingMailer < ApplicationMailer
  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: "Set up your school on Energy Sparks")
  end

  def completion_email
    @school_onboarding = params[:school_onboarding]
    if @school_onboarding.created_by
      make_bootstrap_mail(to: @school_onboarding.created_by.email, subject: "#{@school_onboarding.school_name} has completed the onboarding process")
    end
  end

  def reminder_email
    @school_onboarding = params[:school_onboarding]
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: "Don't forget to set up your school on Energy Sparks")
  end

  def activation_email
    @school = params[:school]
    @to = params[:to]
    @target_prompt = params[:target_prompt]
    make_bootstrap_mail(to: @to, subject: "#{@school.name} is live on Energy Sparks")
  end

  def welcome_email
    @user = params[:user]
    @school = @user.school
    make_bootstrap_mail(to: @user.email, subject: "Welcome to Energy Sparks")
  end
end

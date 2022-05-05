class OnboardingMailer < ApplicationMailer
  helper :application

  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: subject(:onboarding_email))
  end

  def completion_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    if @school_onboarding.created_by
      make_bootstrap_mail(to: 'operations@energysparks.uk', subject: subject(:completion_email, school: @school_onboarding.school_name))
    end
  end

  def reminder_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: "Don't forget to set up your school on Energy Sparks")
  end

  def activation_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    @target_prompt = params[:target_prompt]
    make_bootstrap_mail(to: @to, subject: subject(:activation_email, school: @school.name))
  end

  def onboarded_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: subject(:onboarded_email, school: @school.name))
  end

  def data_enabled_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    @target_prompt = params[:target_prompt]
    make_bootstrap_mail(to: @to, subject: subject(:data_enabled_email, school: @school.name))
  end

  def welcome_email
    @user = params[:user]
    @school = @user.school
    @title = @school.name
    make_bootstrap_mail(to: @user.email, subject: subject(:welcome_email))
  end

  private

  def subject(method, vars = {})
    t(:subject, scope: [:onboarding_mailer, method], **vars)
  end
end

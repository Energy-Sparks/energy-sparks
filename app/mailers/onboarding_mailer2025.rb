# frozen_string_literal: true

class OnboardingMailer2025 < OnboardingMailer
  helper AdvicePageHelper

  def self.enabled?
    Flipper.enabled?(:onboarding_mailer_2025)
  end

  # i18n-tasks-use t('onboarding_mailer2025.onboarded_email.subject')
  # i18n-tasks-use t('onboarding_mailer2025.welcome_email.subject')

  # i18n-tasks-use t('onboarding_mailer2025.welcome_existing.subject')
  def welcome_existing
    @school = params[:school]
    @title = @school.name
    @user = params[:user]
    @top_priority = Schools::Priorities.by_average_one_year_saving(@school.latest_management_priorities).first
    make_bootstrap_mail(to: @user.email, subject: default_i18n_subject(school: @school.name, locale: locale_param))
  end

  # i18n-tasks-use t('onboarding_mailer2025.data_enabled_email.subject')
  def data_enabled_email
    @school = params[:school]
    @users = params[:users]
    @staff = params[:staff]
    @top_priority = Schools::Priorities.by_average_one_year_saving(@school.latest_management_priorities).first
    super
  end
end

# frozen_string_literal: true

class OnboardingMailer < LocaleMailer
  helper :application
  helper AdvicePageHelper

  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    locales = @school_onboarding.email_locales
    @body = for_each_locale(locales) { render :onboarding_email_content, layout: nil }.join('<hr>')
    @subject = for_each_locale(locales) { default_i18n_subject }.join(' / ')
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: @subject)
  end

  def completion_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    @school_group_name = @school_onboarding.school&.school_group&.name
    return unless @school_onboarding.created_by

    subject = default_i18n_subject(school: @school_onboarding.school_name, school_group: @school_group_name)
    make_bootstrap_mail(to: 'operations@energysparks.uk', subject:)
  end

  def reminder_email
    email = params[:email]
    @school_onboardings = params[:school_onboardings]
    locales = @school_onboardings.reduce([]) { |memo, onboarding| memo.union(onboarding.email_locales) }
    @body = for_each_locale(locales) { render :reminder_email_content, layout: nil }.join('<hr>')
    subject = for_each_locale(locales) { default_i18n_subject(count: @school_onboardings.count) }.join(' / ')
    make_bootstrap_mail(to: email, subject: subject)
  end

  # i18n-tasks-use t('onboarding_mailer2025.onboarded_email.subject')
  def onboarded_email
    @school = params[:school]
    @title = @school.name
    @to = user_emails(params[:users])
    make_bootstrap_mail(to: @to, subject: default_i18n_subject(school: @school.name, locale: locale_param))
  end

  def data_enabled_email
    @school = params[:school]
    @users = params[:users]
    @staff = params[:staff]
    management_priorities = @school.latest_management_priorities(exclude_capital: true)
    @top_priority = Schools::Priorities.by_energy_saving(management_priorities).first
    make_bootstrap_mail(to: user_emails(params[:users]),
                        subject: default_i18n_subject(school: @school.name, locale: locale_param))
  end

  def welcome_email
    @school = params[:school]
    @title = @school.name
    @user = params[:user]
    make_bootstrap_mail(to: @user.email)
  end

  def welcome_existing
    @school = params[:school]
    @title = @school.name
    @user = params[:user]
    management_priorities = @school.latest_management_priorities(exclude_capital: true)
    @top_priority = Schools::Priorities.by_energy_saving(management_priorities).first
    make_bootstrap_mail(to: @user.email, subject: default_i18n_subject(school: @school.name, locale: locale_param))
  end
end

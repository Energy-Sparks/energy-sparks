class OnboardingMailer < LocaleMailer
  helper :application

  def onboarding_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    locales = active_locales(@school_onboarding.email_locales)
    @body = for_each_locale(locales) { render :onboarding_email_content, layout: nil }.join("<hr>")
    @subject = for_each_locale(locales) { default_i18n_subject }.join(" / ")
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: @subject)
  end

  def completion_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    if @school_onboarding.created_by
      make_bootstrap_mail(to: 'operations@energysparks.uk', subject:
        default_i18n_subject(school: @school_onboarding.school_name))
    end
  end

  def reminder_email
    @school_onboarding = params[:school_onboarding]
    @title = @school_onboarding.school_name
    locales = active_locales(@school_onboarding.email_locales)
    @body = for_each_locale(locales) { render :reminder_email_content, layout: nil }.join("<hr>")
    @subject = for_each_locale(locales) { default_i18n_subject }.join(" / ")
    make_bootstrap_mail(to: @school_onboarding.contact_email, subject: @subject)
  end

  def activation_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    @target_prompt = params[:target_prompt]
    make_bootstrap_mail(to: @to, subject: default_i18n_subject(school: @school.name))
  end

  def onboarded_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: default_i18n_subject(school: @school.name))
  end

  def data_enabled_email
    @school = params[:school]
    @title = @school.name
    @to = params[:to]
    @target_prompt = params[:target_prompt]
    make_bootstrap_mail(to: @to, subject: default_i18n_subject(school: @school.name))
  end

  def welcome_email
    @user = params[:user]
    @school = @user.school
    @title = @school.name
    make_bootstrap_mail(to: @user.email)
  end
end

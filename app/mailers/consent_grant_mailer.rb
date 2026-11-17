class ConsentGrantMailer < LocaleMailer
  def email_consent
    @consent_grant = params[:consent_grant]
    @title = @consent_grant.school.name
    # i18n-tasks-use t('consent_grant_mailer.email_consent.subject')
    make_bootstrap_mail(to: user_emails(params[:users]))
  end
end

class ConsentRequestMailer < LocaleMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    # i18n-tasks-use t('consent_request_mailer.request_consent.subject')
    make_bootstrap_mail(to: user_emails(params[:users]))
  end
end

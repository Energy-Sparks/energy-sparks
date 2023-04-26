class ConsentGrantMailer < LocaleMailer
  def email_consent
    @consent_grant = params[:consent_grant]
    @title = @consent_grant.school.name
    make_bootstrap_mail(to: user_emails(params[:users]))
  end
end

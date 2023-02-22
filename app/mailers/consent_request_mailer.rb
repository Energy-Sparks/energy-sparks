class ConsentRequestMailer < LocaleMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    emails = user_emails(params[:users])
    make_bootstrap_mail(to: emails)
  end
end

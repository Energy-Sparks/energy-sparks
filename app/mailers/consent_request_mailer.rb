class ConsentRequestMailer < LocaleMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    make_bootstrap_mail(to: user_emails(params[:users]))
  end
end

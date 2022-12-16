class ConsentRequestMailer < LocaleMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    @users = params[:users]

    make_bootstrap_mail_for(to: email_addresses_for_locale(@users))
  end
end

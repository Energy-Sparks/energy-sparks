class ConsentRequestMailer < LocaleMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    email_addressess = email_addresses_for_locale(params[:users])
    make_bootstrap_mail(to: email_addressess) if email_addressess.any?
  end
end

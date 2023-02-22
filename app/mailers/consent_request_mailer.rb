class ConsentRequestMailer < ApplicationMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    email_addressess = email_addresses_for_locale(params[:users])
    make_bootstrap_mail_for_locale(to: email_addressess) if email_addressess.any?
  end
end

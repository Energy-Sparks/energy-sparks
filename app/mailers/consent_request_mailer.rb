class ConsentRequestMailer < ApplicationMailer
  def request_consent
    @school = params[:school]
    make_bootstrap_mail(to: params[:emails], subject: params[:subject])
  end
end

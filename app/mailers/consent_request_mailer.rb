class ConsentRequestMailer < ApplicationMailer
  def request_consent
    @school = params[:school]
    @title = @school.name
    make_bootstrap_mail_en(to: params[:emails])
  end
end

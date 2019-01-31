class AlertMailer < ApplicationMailer
  def alert_email
    @email_address = params[:email_address]
    @alerts = params[:alerts]
    @school = params[:school]
    @unsubscribe_emails = User.where(school: @school, role: :school_admin).pluck(:email).join(', ')

    make_bootstrap_mail(to: @email_address, subject: 'Energy Sparks alerts')
  end
end

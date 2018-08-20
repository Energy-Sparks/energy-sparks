class AlertMailer < ApplicationMailer
  default from: 'hello@energysparks.uk'

  def alert_email
    @email_address = params[:email_address]
    @alerts = params[:alerts]
    @school = params[:school]
    make_bootstrap_mail(to: @email_address, subject: 'Energy Sparks alerts')
  end
end

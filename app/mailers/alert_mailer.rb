class AlertMailer < ApplicationMailer
  default from: 'hello@energysparks.uk'

  def alert_email
    @email_address = params[:email_address]
    @alerts = params[:alerts]
    @school = params[:school]
    mail(to: @email_address, subject: 'Energy Sparks alerts')
  end
end

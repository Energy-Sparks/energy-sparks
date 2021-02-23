class RollbarMailer < ApplicationMailer
  helper :application, :rollbar_mailer
  def report_errors
    subject_description = params[:description] || 'Custom Error Reports'
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    @rollbar_environment = "EnergySparks#{environment_identifier.capitalize}Environment"
    @reported_results = params[:reported_results]
    make_bootstrap_mail(to: 'services@energysparks.uk', subject: "[energy-sparks-#{environment_identifier}] Energy Sparks #{subject_description}: #{Time.zone.today.strftime('%d/%m/%Y')}")
  end
end

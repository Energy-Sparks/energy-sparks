class ImportMailer < ApplicationMailer
  helper :application
  def import_summary
    @data = params[:data]
    @import_logs_with_errors = params[:import_logs_with_errors]
    subject_description = params[:description] || 'import report'
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    make_bootstrap_mail(to: 'services@energysparks.uk', subject: "[energy-sparks-#{environment_identifier}] Energy Sparks #{subject_description}: #{Time.zone.today.strftime('%d/%m/%Y')}")
  end
end

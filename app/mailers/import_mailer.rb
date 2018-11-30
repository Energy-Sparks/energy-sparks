class ImportMailer < ApplicationMailer
  def import_summary
    @logs = params[:logs]
    subject_description = params[:description] || 'import'
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    mail(to: 'services@energysparks.uk', subject: "[energy-sparks-#{environment_identifier}] Energy Sparks #{subject_description}: #{@logs.size} #{'import'.pluralize(@logs.size)} processed")
  end
end

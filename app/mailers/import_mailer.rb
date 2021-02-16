class ImportMailer < ApplicationMailer
  helper :application
  def import_summary
    @meters_running_behind = params[:meters_running_behind]
    @meters_with_blank_data = params[:meters_with_blank_data]
    @meters_with_zero_data = params[:meters_with_zero_data]
    subject_description = params[:description] || 'import report'
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    make_bootstrap_mail(to: 'services@energysparks.uk', subject: "[energy-sparks-#{environment_identifier}] Energy Sparks #{subject_description}: #{Time.zone.today.strftime('%d/%m/%Y')}")
  end
end

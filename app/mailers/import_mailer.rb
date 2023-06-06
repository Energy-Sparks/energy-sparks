class ImportMailer < ApplicationMailer
  helper :application, :issues

  def import_summary
    @meters_running_behind = params[:meters_running_behind]
    @meters_with_blank_data = params[:meters_with_blank_data]
    @meters_with_zero_data = params[:meters_with_zero_data]
    subject_description = params[:description] || 'import report'
    subject = "[energy-sparks-#{environment_identifier}] Energy Sparks #{subject_description}: #{Time.zone.today.strftime('%d/%m/%Y')}"
    attachments[subject + '.csv'] = { mime_type: 'text/csv', content: params[:csv] }
    environment_identifier = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    make_bootstrap_mail(to: 'operations@energysparks.uk', subject: subject)
  end
end

class AdminMailer < ApplicationMailer
  def school_group_meters_report
    to = params[:to]
    csv = params[:csv]
    filename = params[:filename]
    school_group = params[:school_group]
    title = "Meter report for #{school_group.name}"
    env = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    attachments[filename] = { mime_type: 'text/csv', content: csv }
    mail(to: to, subject: "[energy-sparks-#{env}] Energy Sparks - #{title}", body: title)
  end
end

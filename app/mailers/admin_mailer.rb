class AdminMailer < ApplicationMailer
  def school_group_meters_report
    to, csv, filename, school_group = params.values_at(:to, :csv, :filename, :school_group)
    title = "Meter report for #{school_group.name}"
    env = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    attachments[filename] = { mime_type: 'text/csv', content: csv }
    mail(to: to, subject: "[energy-sparks-#{env}] Energy Sparks - #{title}", body: title)
  end
end

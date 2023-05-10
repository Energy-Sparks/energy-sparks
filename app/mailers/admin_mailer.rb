class AdminMailer < ApplicationMailer
  helper :application, :issues

  def school_group_meters_report
    to, meter_report = params.values_at(:to, :meter_report)
    @school_group = meter_report.school_group
    @meters = meter_report.meters
    @all_meters = meter_report.all_meters

    env = ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
    title = "Meter report for #{@school_group.name}"
    attachments[meter_report.csv_filename] = { mime_type: 'text/csv', content: meter_report.csv }

    make_bootstrap_mail(to: to, subject: "[energy-sparks-#{env}] Energy Sparks - #{title}")
  end
end

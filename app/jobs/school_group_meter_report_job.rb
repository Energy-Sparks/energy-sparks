class SchoolGroupMeterReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:, school_group:, meter_scope: {})
    meter_report = SchoolGroups::MeterReport.new(school_group, meter_scope)
    AdminMailer.with(to: to, school_group: school_group, filename: meter_report.csv_filename, csv: meter_report.csv).school_group_meters_report.deliver
  end
end

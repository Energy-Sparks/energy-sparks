class SchoolGroupMeterReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:, school_group:)
    meter_report = SchoolGroups::MeterReport.new(school_group)
    AdminMailer.with(to: to, meter_report: meter_report).school_group_meters_report.deliver
  end
end

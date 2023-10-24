class SchoolGroupMeterReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:, school_group:, all_meters: false)
    meter_report = SchoolGroups::MeterReport.new(school_group, all_meters: all_meters)
    AdminMailer.with(to: to, meter_report: meter_report).school_group_meters_report.deliver
  end
end

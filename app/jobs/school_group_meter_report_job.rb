class SchoolGroupMeterReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to:, school_group:, all_meters:)
    meter_report = SchoolGroups::MeterReport.new(school_group, all_meters:)
    AdminMailer.with(to:, meter_report:).school_group_meters_report.deliver_now
  end
end

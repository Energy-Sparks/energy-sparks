class SchoolGroupMeterReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:, school_group:, meter_scope: {})
    csv = SchoolGroups::Meters::CsvGenerator.new(school_group, meter_scope)
    AdminMailer.with(to: to, school_group: school_group, filename: csv.filename, csv: csv.content).school_group_meters_report.deliver
  end
end

class SendDataSourceReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to, data_source_id, active_only)
    AdminMailer.school_data_source_report(to, data_source_id, active_only).deliver
  end
end

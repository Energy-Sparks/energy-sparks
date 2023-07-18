class SendDataSourceReportJob < ApplicationJob
  queue_as :default

  def priority
    10
  end

  def perform(to:, data_source_id:)
    AdminMailer.with(to: to, data_source_id: data_source_id).school_data_source_report.deliver
  end
end

# frozen_string_literal: true

class SendDataSourceReportJob < ApplicationJob
  queue_as :default

  def priority
    5
  end

  def perform(to, data_source_id, all_meters:)
    AdminMailer.school_data_source_report(to, data_source_id, !all_meters).deliver
  end
end

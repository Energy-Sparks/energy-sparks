# frozen_string_literal: true

module Admin
  class UserExportReportJob < ApplicationJob
    queue_as :default

    def priority
      5
    end

    def perform(to:)
      csv = User.admin_user_export_csv
      AdminMailer.with(to:, csv:).user_export_report.deliver
    end
  end
end

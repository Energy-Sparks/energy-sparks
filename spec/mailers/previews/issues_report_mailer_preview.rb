# frozen_string_literal: true

class IssuesReportMailerPreview < ActionMailer::Preview
  def self.admin_meter_report_params
    { user_id: User.active.where(operations: true).sample }
  end

  def admin_meter_report
    IssuesReportMailer.admin_meter_report(User.find(params[:user_id]), since: 1.year.ago)
  end

  def self.issues_report_params
    admin_meter_report_params
  end

  def issues_report
    IssuesReportMailer.with(user: User.find(params[:user_id])).issues_report
  end
end

class AdminMailer < ApplicationMailer
  helper :application, :issues

  def school_group_meters_report
    to, meter_report = params.values_at(:to, :meter_report)
    @school_group = meter_report.school_group
    @meters = meter_report.meters
    @all_meters = meter_report.all_meters

    title = "Meter report for #{@school_group.name}"
    title += @all_meters ? " - all meters" : " - active meters"
    attachments[meter_report.csv_filename] = { mime_type: 'text/csv', content: meter_report.csv }

    make_bootstrap_mail(to: to, subject: subject(title))
  end

  def issues_report
    @user = params[:user]
    @issues = Issue.for_owned_by(@user).status_open.issue.by_created_at
    title = "Issue report for #{@user.display_name}"
    if @issues.any?
      make_bootstrap_mail(to: @user.email, subject: subject(title))
    end
  end

  private

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end

  def subject(title)
    "[energy-sparks-#{env}] Energy Sparks - #{title}"
  end
end

class TargetMailer < ApplicationMailer
  helper :application

  def first_target
    @school = params[:school]
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: subject(:first_target))
  end

  def first_target_reminder
    @school = params[:school]
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: subject(:first_target_reminder))
  end

  def review_target
    @school = params[:school]
    @to = params[:to]
    make_bootstrap_mail(to: @to, subject: subject(:review_target))
  end

  def admin_target_report
    @to = params[:to]
    @target_summary = params[:target_summary]
    @progress_report = params[:progress_report]
    @target_data_report = params[:target_data_report]

    attach(@progress_report, "progress-report")
    attach(@target_data_report, "target-data-report")

    make_bootstrap_mail(to: @to, subject: "Target Progress and Data Report")
  end

  private

  def attach(report, prefix, suffix = "csv", mime_type = "text/csv")
    if report.present?
      attachments["#{prefix}-#{timestamp}.#{suffix}"] = {
        mime_type: mime_type,
        content: report
      }
    end
  end

  def timestamp
    Time.zone.today.strftime("%Y-%m-%d")
  end

  def subject(method, vars = {})
    t(:subject, scope: [:target_mailer, method], **vars)
  end
end

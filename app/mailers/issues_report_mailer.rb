# frozen_string_literal: true

class IssuesReportMailer < ApplicationMailer
  include Columns
  include ActionView::Helpers::UrlHelper

  helper :application, :issues
  layout 'admin_mailer'

  def issues_report
    @user = params[:user]
    @issues = active_issues(@user).by_review_date.by_updated_at.includes(%i[created_by updated_by issueable])
    return unless @issues.any?

    @columns = columns
    attachments['issues_report.csv'] = { mime_type: 'text/csv', content: csv_report(@columns, @issues) }
    mail(to: @user.email, subject: admin_subject("Issue report for #{@user.display_name}"))
    prevent_delivery_from_test
  end

  private

  def active_issues(user)
    issues = Issue.for_owned_by(user).active.status_open.issue
    issues.where(review_date: ..Date.current)
          .or(issues.where(review_date: Date.current..1.week.from_now))
          .or(issues.where(created_at: 1.week.ago.to_date..))
  end

  def columns # rubocop:disable Metrics/AbcSize -- breaking up seems to make more complex
    [Column.new(:issue_type, ->(issue) { issue.issue_type }, display: :csv),
     Column.new(:issue_for, ->(issue) { issue.issueable&.name }),
     Column.new(:new, ->(issue) { issue.created_at > 1.week.ago ? 'New this week!' : '' }, display: :csv),
     Column.new(:group,
                ->(issue) { issue.school_group&.name },
                ->(issue, csv) { csv && link_to(csv, admin_school_group_url(issue.school_group)) }),
     Column.new(:title, ->(issue) { issue.title }),
     Column.new(:fuel, ->(issue) { issue.fuel_type&.humanize }),
     Column.new(:next_review_date, ->(issue) { format_date(issue.review_date) }),
     Column.new(:created_by, ->(issue) { issue.created_by.display_name }),
     Column.new(:created, ->(issue) { format_date(issue.created_at) }),
     Column.new(:updated_by, ->(issue) { issue.updated_by.display_name }),
     Column.new(:updated, ->(issue) { format_date(issue.updated_at) }),
     Column.new(:view, ->(issue) { polymorphic_url([:admin, issue.issueable, issue]) }, display: :csv),
     Column.new(:edit, ->(issue) { edit_polymorphic_url([:admin, issue.issueable, issue]) })]
  end

  def format_date(date)
    date&.strftime('%d/%m/%Y')
  end
end

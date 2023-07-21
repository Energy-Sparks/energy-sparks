class AdminMailer < ApplicationMailer
  helper :application, :issues

  def school_data_source_report
    to, data_source_id = params.values_at(:to, :data_source_id)
    @data_source = DataSource.find(data_source_id)
    title = "#{t('common.application')}-#{@data_source.name}-meters-#{Time.zone.now.iso8601}".parameterize
    attachments[(title + '.csv')] = { mime_type: 'text/csv', content: @data_source.to_csv }

    make_bootstrap_mail(to: to, subject: subject(title))
  end

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
    @issues = Issue.for_owned_by(@user).status_open.issue.by_updated_at.includes([:created_by, :updated_by, :issueable])
    title = "Issue report for #{@user.display_name}"

    if @issues.any?
      attachments['issues_report.csv'] = { mime_type: 'text/csv', content: build_issues_csv_for(@issues) }
      make_bootstrap_mail(to: @user.email, subject: subject(title))
    end
  end

  def funder_allocation_report
    to, funder_report = params.values_at(:to, :funder_report)
    title = "Funder allocation report #{Time.zone.today.iso8601}"
    attachments[funder_report.csv_filename] = { mime_type: 'text/csv', content: funder_report.csv }
    make_bootstrap_mail(to: to, subject: subject(title))
  end

  private

  def build_issues_csv_for(issues)
    CSV.generate(headers: true) do |csv|
      csv << ['Issue type', 'Issue for', '', 'Group', 'Title', 'Fuel', 'Created By', 'Created', 'Updated By', 'Updated', 'View', 'Edit']
      issues.each do |issue|
        csv << [
          issue.issue_type,
          issue&.issueable&.name,
          issue.created_at > 1.week.ago ? 'New this week!' : '',
          issue&.school_group&.name,
          issue.title,
          issue.fuel_type&.humanize,
          issue.created_by.display_name,
          issue.created_at.strftime('%d/%m/%Y'),
          issue.updated_by.display_name,
          issue.updated_at.strftime('%d/%m/%Y'),
          polymorphic_url([:admin, issue.issueable, issue]),
          edit_polymorphic_url([:admin, @issueable, issue])
        ]
      end
    end
  end

  def env
    ENV['ENVIRONMENT_IDENTIFIER'] || 'unknown'
  end

  def subject(title)
    "[energy-sparks-#{env}] Energy Sparks - #{title}"
  end
end

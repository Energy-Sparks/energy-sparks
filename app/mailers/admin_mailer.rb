class AdminMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def school_data_source_report
    to, data_source_id = params.values_at(:to, :data_source_id)
    @data_source = DataSource.find(data_source_id)
    title = "#{t('common.application')}-#{@data_source.name}-meters-#{Time.zone.now.iso8601}".parameterize
    attachments[(title + '.csv')] = { mime_type: 'text/csv', content: @data_source.to_csv }

    mail(to: to, subject: subject(title))
  end

  def school_procurement_route_report
    to, procurement_route_id = params.values_at(:to, :procurement_route_id)
    @procurement_route = ProcurementRoute.find(procurement_route_id)
    title = "#{t('common.application')}-#{@procurement_route.organisation_name}-meters-#{Time.zone.now.iso8601}".parameterize
    attachments[(title + '.csv')] = { mime_type: 'text/csv', content: @procurement_route.to_csv }

    mail(to: to, subject: subject(title))
  end

  def school_group_meters_report
    to, meter_report = params.values_at(:to, :meter_report)
    @school_group = meter_report.school_group
    @meters = meter_report.meters
    @all_meters = meter_report.all_meters

    title = "Meter report for #{@school_group.name}"
    title += @all_meters ? ' - all meters' : ' - active meters'
    attachments[meter_report.csv_filename] = { mime_type: 'text/csv', content: meter_report.csv }

    mail(to: to, subject: subject(title))
  end

  def school_group_meter_data_report
    @school_group = params[:school_group]
    time = Time.current
    Dir.mktmpdir do |dir|
      files_dir = File.join(dir, 'files')
      Dir.mkdir(files_dir)
      @school_group.schools.data_visible.find_each do |school|
        csv = CsvDownloader.readings_to_csv(
          AmrValidatedReading.download_query_for_school(school, extra_selects: ['schools.name', 'schools.id'])
                             .joins(meter: :school).where(meters: { active: true }).to_sql,
          "School Name,School Id,#{AmrValidatedReading::CSV_HEADER_FOR_SCHOOL}"
        )
        File.write(File.join(files_dir, EnergySparks::Filenames.csv(school.slug, time:)), csv)
      end
      entries = Dir.entries(files_dir) - %w[. ..]
      zip_path = File.join(dir,
                           EnergySparks::Filenames.name("#{@school_group.slug}-meter-data", time:, extension: :zip))
      Zip::File.open(zip_path, create: true) do |zipfile|
        entries.each { |entry| zipfile.add(entry, File.join(files_dir, entry)) }
      end
      attachments[File.basename(zip_path)] = File.read(zip_path)
      mail(to: params[:to], subject: "Meter data report for #{@school_group.name}")
    end
  end

  def issues_report
    @user = params[:user]
    @issues = Issue.for_owned_by(@user).status_open.issue.by_updated_at.includes(%i[created_by updated_by issueable])
    title = "Issue report for #{@user.display_name}"

    return unless @issues.any?

    attachments['issues_report.csv'] = { mime_type: 'text/csv', content: build_issues_csv_for(@issues) }
    mail(to: @user.email, subject: subject(title))
  end

  def funder_allocation_report
    to, funder_report = params.values_at(:to, :funder_report)
    title = "Funder allocation report #{Time.zone.today.iso8601}"
    attachments[funder_report.csv_filename] = { mime_type: 'text/csv', content: funder_report.csv }
    mail(to: to, subject: subject(title))
  end

  def engaged_schools_report(to, csv, previous_year, school_group_id)
    school_group = SchoolGroup.find(school_group_id) if school_group_id.present?
    now = Time.zone.now.iso8601
    filename = ['engaged-schools-report']
    filename << school_group.name.parameterize if school_group
    filename << 'previous-year' if previous_year
    filename << now.tr(':', '-')
    attachments["#{filename.join('-')}.csv"] = { mime_type: 'text/csv', content: csv }
    subject = ['Engaged schools report']
    subject << "for #{school_group.name}" if school_group
    subject << '(previous year)' if previous_year
    subject << now
    mail(to:, subject: subject.join(' '))
  end

  def stopped_data_feeds
    @missing = params[:missing]
    mail(to: params[:to], subject: subject('Stopped data feeds'))
  end

  private

  def build_issues_csv_for(issues)
    CSV.generate(headers: true) do |csv|
      csv << ['Issue type', 'Issue for', '', 'Group', 'Title', 'Fuel', 'Created By', 'Created', 'Updated By',
              'Updated', 'View', 'Edit']
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

  def subject(title)
    "[energy-sparks-#{env}] Energy Sparks - #{title}"
  end
end

# frozen_string_literal: true

class ImportMailer < ApplicationMailer
  helper :application, :issues
  layout 'admin_mailer'

  def import_summary
    @meters_running_behind = params[:meters_running_behind]
    @meters_with_blank_data = params[:meters_with_blank_data]
    @meters_with_zero_data = params[:meters_with_zero_data]
    subject_description = params[:description] || 'import report'
    subject = "[energy-sparks-#{env}] Energy Sparks #{subject_description}: #{Time.zone.today.strftime('%d/%m/%Y')}"
    attachments[EnergySparks::Filenames.csv(subject_description.parameterize)] = { mime_type: 'text/csv',
                                                                                   content: to_csv }
    mail(to: 'operations@energysparks.uk', subject: subject)
  end

  private

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_header
      @meters_running_behind.each { |meter| csv << csv_row_for('Meter with stale data', meter) }
      @meters_with_blank_data.each { |meter| csv_row_for('Meter with blank readings (whole day)', meter) }
      @meters_with_zero_data.each { |meter| csv << csv_row_for('Zero data import (whole day)', meter) }
    end
  end

  def csv_header
    [
      '',
      'Area',
      'Meter type',
      'School',
      'MPAN/MPRN',
      'Meter system',
      'Data source',
      'Procurement route',
      'Last validated reading date',
      'Admin meter status',
      'Manual reads',
      'Issues',
      'Notes',
      'Group admin name'
    ]
  end

  def csv_row_for(title, meter)
    [
      title,
      meter.school&.school_group&.name,
      meter.meter_type.to_s.humanize,
      meter.school.name,
      meter.mpan_mprn,
      meter.t_meter_system,
      meter.data_source&.name,
      meter.procurement_route&.organisation_name,
      meter.last_validated_reading&.strftime('%d/%m/%Y'),
      meter.admin_meter_status_label,
      meter.manual_reads ? 'Y' : 'N',
      meter.issues.issue.count,
      meter.issues.note.count,
      meter.school&.school_group&.default_issues_admin_user&.name
    ]
  end
end

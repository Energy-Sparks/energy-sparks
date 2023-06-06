class ImportNotifier
  # include Rails.application.routes.url_helpers

  def initialize(description: nil)
    @description = description
  end

  def meters_running_behind
    find_meters_running_behind.sort_by do |meter|
      [
        meter.school.area_name.to_s,
        meter.meter_type,
        meter.school_name,
        meter.mpan_mprn
      ]
    end
  end

  #data feed readings, creating in last 24 hours, where the readings are ALL blank
  #nil, numeric, string values are not blank, so this equates to an array of ['']
  def meters_with_blank_data(from: 24.hours.ago, to: Time.zone.now)
    meters = Meter.active
    .joins(:amr_data_feed_readings)
    .where("amr_data_feed_readings.readings = ARRAY[?]", Array.new(48, '')) #where readings is empty string
    .joins("INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id") #manually join to import logs
    .where('import_time BETWEEN :from AND :to', from: from, to: to) #limit to period
    .distinct #distinct meters
    meters.sort_by {|m| [m.school.area_name, m.meter_type, m.school_name, m.mpan_mprn]}
  end

  #data feed readings, creating in last 24 hours, where the readings are ALL 0 or 0.0
  #this version is slightly different to original as that used ruby to cast values to a float
  #this meant any dodgy chars, e.g. '-', where treated as 0.0
  def meters_with_zero_data(from: 24.hours.ago, to: Time.zone.now)
    meters = Meter.active
    .where.not(meter_type: :exported_solar_pv) # exported solar PV is legitimately zero on some days
    .joins(:amr_data_feed_readings)
    .where("amr_data_feed_readings.readings = ARRAY[?] OR amr_data_feed_readings.readings = ARRAY[?]", Array.new(48, '0'), Array.new(48, '0.0')) #where readings are 0, or 0.0
    .joins("INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id") #manually join to import logs
    .where('import_time BETWEEN :from AND :to', from: from, to: to) #limit to period
    .distinct #distinct meters
    meters.sort_by {|m| [m.school.area_name, m.meter_type, m.school_name, m.mpan_mprn]}
  end

  def notify(from:, to:)
    ImportMailer.with(meters_running_behind: meters_running_behind, meters_with_blank_data: meters_with_blank_data(from: from, to: to), meters_with_zero_data: meters_with_zero_data(from: from, to: to), description: @description, csv: to_csv).import_summary.deliver_now
  end

  def to_csv
    CSV.generate(headers: true) do |csv|
      csv << csv_header
      meters_running_behind.each { |meter| csv << csv_row_for('Meter with stale data', meter) }
      meters_with_blank_data.each { |meter| csv_row_for('Meter with blank readings (whole day)', meter) }
      meters_with_zero_data.each { |meter| csv << csv_row_for('Zero data import (whole day)', meter) }
    end
  end

  private

  def csv_header
    [
      '',
      'Area',
      'Meter type',
      'School',
      'MPAN/MPRN',
      'Data source',
      'Procurement route',
      'Last validated reading date',
      'Admin meter status',
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
      meter.data_source&.name,
      meter.procurement_route&.organisation_name,
      meter.last_validated_reading&.strftime('%d/%m/%Y'),
      meter.admin_meter_status_label,
      meter.issues.issue.count,
      meter.issues.note.count,
      meter.school&.school_group&.default_issues_admin_user&.name
    ]
  end

  def find_meters_running_behind
    Meter.active
         .joins(:school)
         .joins('LEFT JOIN data_sources on data_sources.id = meters.data_source_id')
         .joins(:amr_validated_readings)
         .group('meters.id, data_sources.import_warning_days')
         .having(
           <<-SQL.squish
             MAX(amr_validated_readings.reading_date) < NOW() - COALESCE(
                                                                       data_sources.import_warning_days,
                                                                       (
                                                                          SELECT site_settings.default_import_warning_days
                                                                          FROM site_settings
                                                                          ORDER BY created_at
                                                                          DESC
                                                                          LIMIT 1
                                                                        )
                                                                     ) * '1 day'::interval
           SQL
         )
  end
end

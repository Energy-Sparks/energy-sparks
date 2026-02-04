class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def meters_running_behind
    find_meters_running_behind
  end

  # data feed readings, creating in last 24 hours, where the readings are ALL blank
  # nil, numeric, string values are not blank, so this equates to an array of ['']
  def meters_with_blank_data(from: 24.hours.ago, to: Time.zone.now)
    Meter.active
    .joins(:school)
    .joins(:amr_data_feed_readings)
    .joins('INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id') # manually join to import logs
    .where(schools: { active: true })
    .where('import_time BETWEEN :from AND :to', from: from, to: to) # limit to period
    .where('amr_data_feed_readings.readings = ARRAY[?]', Array.new(48, '')) # where readings is empty string
    .includes(:school, { school: :school_group }, :procurement_route, :data_source, :admin_meter_status, :issues)
    .distinct # distinct meters
    .order({ school_groups: { name: :asc } }, :meter_type, { schools: { name: :asc } }, :mpan_mprn)
  end

  # data feed readings, creating in last 24 hours, where the readings are ALL 0 or 0.0
  # this version is slightly different to original as that used ruby to cast values to a float
  # this meant any dodgy chars, e.g. '-', where treated as 0.0
  def meters_with_zero_data(from: 24.hours.ago, to: Time.zone.now)
    Meter.active
    .joins(:school)
    .joins(:amr_data_feed_readings)
    .joins('INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id') # manually join to import logs
    .where.not(meter_type: :exported_solar_pv) # exported solar PV is legitimately zero on some days
    .where(schools: { active: true })
    .where('import_time BETWEEN :from AND :to', from: from, to: to) # limit to period
    .where('amr_data_feed_readings.readings = ARRAY[?] OR amr_data_feed_readings.readings = ARRAY[?]', Array.new(48, '0'), Array.new(48, '0.0')) # where readings are 0, or 0.0
    .includes(:school, { school: :school_group }, :procurement_route, :data_source, :admin_meter_status, :issues)
    .distinct # distinct meters
    .order({ school_groups: { name: :asc } }, :meter_type, { schools: { name: :asc } }, :mpan_mprn)
  end

  def notify(from:, to:)
    ImportMailer.with(meters_running_behind: meters_running_behind, meters_with_blank_data: meters_with_blank_data(from: from, to: to), meters_with_zero_data: meters_with_zero_data(from: from, to: to), description: @description).import_summary.deliver_now
  end

  private

  def find_meters_running_behind
    outdated_meter_ids = Meter
      .joins('LEFT JOIN data_sources ON data_sources.id = meters.data_source_id')
      .joins(:school)
      .joins(<<~SQL.squish)
        JOIN LATERAL (
          SELECT id, reading_date
          FROM amr_validated_readings
          WHERE amr_validated_readings.meter_id = meters.id
          ORDER BY reading_date DESC
          LIMIT 1
        ) AS max_reading ON true
      SQL
      .where(active: true, schools: { active: true })
      .where(<<~SQL.squish)
        max_reading.reading_date <
          NOW() - COALESCE(
            data_sources.import_warning_days,
            (
              SELECT site_settings.default_import_warning_days
              FROM site_settings
              ORDER BY created_at DESC
              LIMIT 1
            )
          ) * INTERVAL '1 day'
      SQL
      .pluck(:id)

    Meter
        .includes(:school, { school: :school_group }, :procurement_route, :data_source, :admin_meter_status, :issues)
        .where(id: outdated_meter_ids)
        .order({ school_groups: { name: :asc } }, :meter_type, :school_id, :mpan_mprn)
  end
end

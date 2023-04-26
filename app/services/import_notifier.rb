class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def meters_running_behind
    meters = Meter.active
    .joins(:amr_data_feed_readings)
    .where("amr_data_feed_readings.created_at >= NOW() - INTERVAL '1 year'")
    .joins("INNER JOIN amr_data_feed_configs on amr_data_feed_readings.amr_data_feed_config_id = amr_data_feed_configs.id")
    .where.not("amr_data_feed_configs.import_warning_days" => nil)
    .joins(:amr_validated_readings)
    .group('meters.id')
    .having("MAX(amr_validated_readings.reading_date) < NOW() - MIN(amr_data_feed_configs.import_warning_days) * '1 day'::interval")
    meters.sort_by {|m| [m.school.area_name, m.meter_type, m.school_name, m.mpan_mprn]}
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
    ImportMailer.with(meters_running_behind: meters_running_behind, meters_with_blank_data: meters_with_blank_data(from: from, to: to), meters_with_zero_data: meters_with_zero_data(from: from, to: to), description: @description).import_summary.deliver_now
  end
end

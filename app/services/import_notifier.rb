class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def meters_running_behind
    find_with_config do |config|
      if config.import_warning_days.present?
        Meter.active
          #that have ever had readings loaded from this config (~ data source)
          .joins(:amr_data_feed_readings).where("amr_data_feed_readings.amr_data_feed_config_id=?", config.id)
          #and where the latest validated reading is older than what we expect in the config
          .joins(:amr_validated_readings).group('meters.id').having("MAX(amr_validated_readings.reading_date) < NOW() - INTERVAL '? days'", config.import_warning_days)
      else
        []
      end
    end
  end

  #data feed readings, creating in last 24 hours, where the readings are ALL blank
  #nil, numeric, string values are not blank, so this equates to an array of ['']
  def meters_with_blank_data(from: 24.hours.ago, to: Time.zone.now)
    Meter.active
    .joins(:amr_data_feed_readings)
    .where("amr_data_feed_readings.readings = ARRAY[?]", Array.new(48, '')) #where readings is empty string
    .joins("INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id") #manually join to import logs
    .where('import_time BETWEEN :from AND :to', from: from, to: to) #limit to period
    .distinct #distinct meters
  end

  #data feed readings, creating in last 24 hours, where the readings are ALL 0 or 0.0
  #this version is slightly different to original as that used ruby to cast values to a float
  #this meant any dodgy chars, e.g. '-', where treated as 0.0
  def meters_with_zero_data(from: 24.hours.ago, to: Time.zone.now)
    Meter.active
    .where.not(meter_type: :exported_solar_pv) # exported solar PV is legitimately zero on some days
    .joins(:amr_data_feed_readings)
    .where("amr_data_feed_readings.readings = ARRAY[?] OR amr_data_feed_readings.readings = ARRAY[?]", Array.new(48, '0'), Array.new(48, '0.0')) #where readings are 0, or 0.0
    .joins("INNER JOIN amr_data_feed_import_logs on amr_data_feed_readings.amr_data_feed_import_log_id = amr_data_feed_import_logs.id") #manually join to import logs
    .where('import_time BETWEEN :from AND :to', from: from, to: to) #limit to period
    .distinct #distinct meters
  end

  def notify(from:, to:)
    ImportMailer.with(meters_running_behind: meters_running_behind, meters_with_blank_data: meters_with_blank_data(from: from, to: to), meters_with_zero_data: meters_with_zero_data(from: from, to: to), description: @description).import_summary.deliver_now
  end

  private

  def find_with_config
    meters = []
    AmrDataFeedConfig.order(:description).each do |config|
      meters = meters | yield(config)
    end
    meters.sort_by {|m| [m.school.area_name, m.meter_type, m.school_name, m.mpan_mprn]}
  end
end

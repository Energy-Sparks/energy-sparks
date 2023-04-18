class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def meters_running_behind
    find_with_config do |config|
      if config.import_warning_days.present?
        #Leaving this here for the moment to document original behaviour
        #config.meters.select {|meter| meter.last_validated_reading && meter.last_validated_reading < config.import_warning_days.days.ago}

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

  def meters_with_blank_data(from: 24.hours.ago, to: Time.zone.now)
    find_with_config do |config|
      import_logs = config.amr_data_feed_import_logs.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
      all_log_meters = import_logs.map do |log|
        log.amr_data_feed_readings.select {|reading| reading.readings.blank? || reading.readings.all?(&:blank?)}.map(&:meter).compact
      end
      all_log_meters.flatten.uniq
    end
  end

  def meters_with_zero_data(from: 24.hours.ago, to: Time.zone.now)
    find_with_config do |config|
      import_logs = config.amr_data_feed_import_logs.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
      all_log_meters = import_logs.map do |log|
        log.amr_data_feed_readings.select {|reading| reading.readings.present? && reading.readings.all? {|x48| x48.to_f == 0.0 rescue true}}.map(&:meter).compact
      end
      uniq_log_meters = all_log_meters.flatten.uniq
      # exported solar PV is legitimately zero on some days
      uniq_log_meters.reject(&:exported_solar_pv?)
    end
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
    meters.reject {|m| !m.active? }.sort_by {|m| [m.school.area_name, m.meter_type, m.school_name, m.mpan_mprn]}
  end
end

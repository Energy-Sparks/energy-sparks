class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def data(from:, to:)
    AmrDataFeedConfig.order(:description).inject({}) do |collection, config|
      import_logs = config.amr_data_feed_import_logs.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
      collection[config] = {
        import_logs: import_logs,
        meters_running_behind: meters_running_behind(config).sort_by(&:school_name),
        meters_with_blank_data: meters_with_blank_data(import_logs).sort_by(&:school_name),
        meters_with_zero_data: meters_with_zero_data(import_logs).sort_by(&:school_name)
      }
      collection
    end
  end

  def notify(from:, to:)
    ImportMailer.with(data: data(from: from, to: to), description: @description, import_logs_with_errors: import_logs_with_errors(from: from, to: to)).import_summary.deliver_now
  end

  def import_logs_with_errors(from: 2.days.ago, to: Time.zone.today)
    AmrDataFeedImportLog.errored.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
  end

  private

  def meters_running_behind(config)
    return [] if config.import_warning_days.blank?
    config.meters.select {|meter| meter.last_validated_reading && meter.last_validated_reading < config.import_warning_days.days.ago}
  end

  def meters_with_blank_data(import_logs)
    all_log_meters = import_logs.map do |log|
      log.amr_data_feed_readings.select {|reading| reading.readings.blank? || reading.readings.all?(&:blank?)}.map(&:meter).compact
    end
    all_log_meters.flatten.uniq
  end

  def meters_with_zero_data(import_logs)
    all_log_meters = import_logs.map do |log|
      log.amr_data_feed_readings.select {|reading| reading.readings.present? && reading.readings.all? {|x48| x48.to_f == 0.0 rescue true}}.map(&:meter).compact
    end
    uniq_log_meters = all_log_meters.flatten.uniq
    # exported solar PV is legitimately zero on some days
    uniq_log_meters.reject(&:exported_solar_pv?)
  end
end

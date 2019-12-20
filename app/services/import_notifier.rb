class ImportNotifier
  def initialize(description: nil)
    @description = description
  end

  def data(from:, to:)
    AmrDataFeedConfig.order(:description).inject({}) do |collection, config|
      import_logs = config.amr_data_feed_import_logs.where('import_time BETWEEN ? AND ?', from, to).order(:import_time)
      meters_running_behind = import_logs.map do |_log|
        config.meters.select {|meter| meter.last_validated_reading && meter.last_validated_reading < config.import_warning_days.days.ago}
      end
      meters_with_blank_data = import_logs.map do |log|
        log.amr_data_feed_readings.select {|reading| reading.readings.blank? || reading.readings.all?(&:blank?)}.map(&:meter).compact
      end
      meters_with_zero_data = import_logs.map do |log|
        log.amr_data_feed_readings.select {|reading| reading.readings.present? && reading.readings.all? {|x48| x48.to_f == 0.0 rescue true}}.map(&:meter).compact
      end

      collection[config] = {
        import_logs: import_logs,
        meters_running_behind: meters_running_behind.flatten.sort_by(&:school_name),
        meters_with_blank_data: meters_with_blank_data.flatten.uniq.sort_by(&:school_name),
        meters_with_zero_data: meters_with_zero_data.flatten.uniq.sort_by(&:school_name)
      }
      collection
    end
  end

  def notify(from:, to:)
    ImportMailer.with(data: data(from: from, to: to), description: @description).import_summary.deliver_now
  end
end

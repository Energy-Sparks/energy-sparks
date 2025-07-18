module Amr
  class ProcessAmrReadingData
    def initialize(amr_data_feed_config, amr_data_feed_import_log)
      @amr_data_feed_config = amr_data_feed_config
      @amr_data_feed_import_log = amr_data_feed_import_log
      @meter_data = Meter.hash_of_meter_data
    end

    def perform(valid_readings, warning_readings)
      DataFeedUpserter.new(@amr_data_feed_config, @amr_data_feed_import_log, valid_readings).perform
      create_warnings(warning_readings) unless warning_readings.empty?
      @amr_data_feed_import_log
    end

    private

    def create_warnings(warnings)
      updated_warnings = warnings.map do |warning|
        {
          amr_data_feed_import_log_id: @amr_data_feed_import_log.id,
          warning_types: warning[:warnings].map { |warning_symbol| AmrReadingWarning::WARNINGS.key(warning_symbol.to_sym) },
          created_at: DateTime.now.utc,
          updated_at: DateTime.now.utc,
          mpan_mprn: warning[:mpan_mprn],
          school_id: school_id(warning),
          fuel_type: fuel_type(warning),
          reading_date: warning[:reading_date],
          readings: warning[:readings]
         }
      end
      AmrReadingWarning.insert_all(updated_warnings)
    end

    def school_id(warning)
      @meter_data[warning[:mpan_mprn]][:school_id] if @meter_data.key?(warning[:mpan_mprn])
    end

    def fuel_type(warning)
      @meter_data[warning[:mpan_mprn]][:fuel_type] if @meter_data.key?(warning[:mpan_mprn])
    end
  end
end

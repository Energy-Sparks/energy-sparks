# frozen_string_literal: true

module Amr
  class PerseUpsert
    def initialize
      @config = AmrDataFeedConfig.find_by(identifier: 'perse-half-hourly-api')
    end

    def perform(meter, reload: false)
      raise 'perse-half-hourly-api AmrDataFeedConfig missing' if @config.nil?

      date = calculate_from_date(meter, reload)
      log = create_log(meter, date)
      data = api.meter_history_realtime_data(meter.mpan_mprn, date)
      reading_hashes = process_data(data).map do |reading_date, readings|
        { mpan_mprn: meter.mpan_mprn,
          reading_date:,
          readings:,
          amr_data_feed_config_id: @config.id,
          meter_id: meter.id }
      end
      DataFeedUpserter.new(@config, log, reading_hashes).perform
    rescue StandardError => e
      EnergySparks::Log.exception(e, source: :perse_upsert, meter_id: meter.mpan_mprn, date:, data:)
      log&.update!(error_messages: "Error downloading data for #{meter.mpan_mprn} from #{date} : #{e.message}")
      log
    end

    def latest_reading_date(meter)
      AmrDataFeedReading.where(amr_data_feed_config: @config, meter:).maximum(:reading_date) if @config
    end

    private

    def calculate_from_date(meter, reload)
      date = 14.months.ago
      unless reload
        latest = latest_reading_date(meter)
        # go back 7 days in case any data was missing
        date = Date.parse(latest) - 7.days if latest
      end
      date
    end

    def create_log(meter, date)
      AmrDataFeedImportLog.create(
        amr_data_feed_config: @config,
        file_name: "Perse API import for #{meter.mpan_mprn} for #{date}",
        import_time: DateTime.now.utc,
        records_imported: 0
      )
    end

    def api
      @api ||= DataFeeds::PerseApi.new
    end

    def process_data(data)
      data['data']&.select { |reading| reading_ok(reading) }
                  &.map { |reading| [reading['Date'], (1..48).map { |i| to_f_if_not_nil(reading["P#{i}"]) }] } || []
    end

    def reading_ok(reading)
      reading['MeasurementQuantity'] == 'AI' && (1..48).all? { |i| reading["UT#{i}"] == 'A' }
    end

    def to_f_if_not_nil(item)
      # not sure these would ever be nil because of the data check above but just to make sure we don't turn a nil into a 0
      item.blank? ? nil : item.to_f
    end
  end
end

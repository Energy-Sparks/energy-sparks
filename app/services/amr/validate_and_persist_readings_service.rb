require 'dashboard'

module Amr
  class ValidateAndPersistReadingsService
    def initialize(active_record_school, logger = Rails.logger)
      @active_record_school = active_record_school
      @logger = logger
    end

    def perform
      return unless @active_record_school.meters_with_readings.any?

      unvalidated_data = AnalyticsMeterCollectionFactory.new(@active_record_school).unvalidated_data
      save_to_s3(unvalidated_data)
      meter_collection = MeterCollectionFactory.build(unvalidated_data)

      @logger.info('Created meter collection from unvalidated data')

      AggregateDataService.new(meter_collection).validate_meter_data

      @logger.info('Validated meter data')

      UpsertValidatedReadings.new(meter_collection).perform

      @logger.info('Completed database updates for validated readings')

      # this will cause a cache miss when requesting the meter collection
      @active_record_school.invalidate_cache_key

      meter_collection
    end

    def save_to_s3(data)
      bucket = ENV['UNVALIDATED_SCHOOL_CACHE_BUCKET']
      return unless Flipper.enabled?(:save_unvalidated_data_to_s3) && bucket

      s3 = Aws::S3::Client.new
      key = "unvalidated-data-#{@active_record_school.name.parameterize}.yaml.gz"
      s3.put_object(bucket:, key:, body: gzip(YAML.dump(data)))
    end

    def gzip(data)
      io = StringIO.new
      Zlib::GzipWriter.wrap(io) { |gzip| gzip.write(data) }
      io.string
    end
  end
end

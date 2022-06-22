module Transifex
  class Loader
    def initialize(locale = :cy, logger = Rails.logger)
      @locale = locale
      @logger = logger
    end

    def perform
      transifex_load = TransifexLoad.create!
      @logger.info("Synchronising Activity Types")
      synchronise_resources(transifex_load, ActivityType.active.order(:id))
    end

    private

    #synchronise a list of individual resources
    def synchronise_resources(transifex_load, tx_serialisable_resources)
      counter = OpenStruct.new(total_pulled: 0, total_pushed: 0)
      tx_serialisable_resources.each do |tx_serialisable|
        process_tx_serialisable(transifex_load, tx_serialisable, counter)
      end
      transifex_load.update!(
        pushed: transifex_load.pushed + counter.total_pushed,
        pulled: transifex_load.pulled + counter.total_pulled
      )
    end

    def process_tx_serialisable(transifex_load, tx_serialisable, counter)
      begin
        synchroniser = Synchroniser.new(tx_serialisable, @locale)
        counter.total_pulled += 1 if synchroniser.pull
        counter.total_pushed += 1 if synchroniser.push
      rescue => error
        log_error(transifex_load, tx_serialisable, error)
      end
    end

    def log_error(transifex_load, tx_serialisable, error)
      Rollbar.error(error,
        job: :transifex_load,
        record_type: tx_serialisable.class.name,
        record_id: tx_serialisable.id
      )
      transifex_load.transifex_load_errors.create!(
        record_type: tx_serialisable.class.name,
        record_id: tx_serialisable.id,
        error: error.message
      )
    end
  end
end

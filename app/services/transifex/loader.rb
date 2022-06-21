module Transifex
  class Loader
    def initialize(logger = Rails.logger)
      @logger = logger
    end

    def perform
      transifex_load = TransifexLoad.new

      log("Synchronising Activity Types")
      synchronise_activity_types(transifex_load)
    end

    private

    def synchronise_activity_types(transifex_load)
      total_pulled = 0
      total_pushed = 0
      ActivityType.transifex_list.each do |at|
        process_tx_serialisable(transifex_load, at, total_pulled, total_pushed)
      end
      #load.update!(
      #   pushed: load.pushed + total_pushed,
      #   pulled: load.pulled + total_pulled
      #)
    end

    def process_tx_serialisable(transifex_load, tx_serialisable)
      begin
        synchroniser = Synchroniser.new(tx_serialisable)
        synchroniser.pull
        #total_pulled += 1 if pulled
        synchroniser.push
        #total_pushed += 1 if pushed
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

    def log(msg)
      puts msg
      @logger.info(msg)
    end
  end
end

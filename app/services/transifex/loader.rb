module Transifex
  class Loader
    def initialize(locale = :cy, logger = Rails.logger)
      @locale = locale
      @logger = logger
    end

    def perform
      transifex_load = TransifexLoad.create!(status: :running)
      begin
        log("Synchronising Activity Types")
        synchronise_resources(transifex_load, ActivityType.active.order(:id))
        log("Synchronising Intervention Types")
        synchronise_resources(transifex_load, InterventionType.active.order(:id))
        log("Synchronising Activity Categories")
        synchronise_resources(transifex_load, ActivityCategory.all.order(:id))
        log("Synchronising Intervention Type Groups")
        synchronise_resources(transifex_load, InterventionTypeGroup.all.order(:id))
        log("Synchronising Help Pages")
        synchronise_resources(transifex_load, HelpPage.all.order(:id))
        log("Synchronising Case Studies")
        synchronise_resources(transifex_load, CaseStudy.all.order(:id))
      rescue => error
        #ensure all errors are caught and logged
        log_error(transifex_load, error)
      end
      transifex_load.update!(status: :done)
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
        log("processing #{tx_serialisable.resource_key}")
        counter.total_pulled += 1 if synchroniser.pull
        counter.total_pushed += 1 if synchroniser.push
      rescue => error
        log("error processing #{tx_serialisable.resource_key}")
        log_error(transifex_load, error, tx_serialisable)
      end
    end

    def log_error(transifex_load, error, tx_serialisable = nil)
      if tx_serialisable.present?
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
      else
        Rollbar.error(error, job: :transifex_load)
        transifex_load.transifex_load_errors.create!(error: error.message)
      end
    end

    def log(msg)
      @logger.info("Transifex Loader: #{msg}")
    end
  end
end

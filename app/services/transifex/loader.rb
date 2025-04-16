module Transifex
  class Loader
    def initialize(locale = :cy, logger = Rails.logger, full_sync = true)
      @locale = locale
      @logger = logger
      @full_sync = full_sync
    end

    def perform
      transifex_load = TransifexLoad.create!(status: :running)
      begin
        log('Synchronising Activity Types')
        synchronise_resources(transifex_load, ActivityType.tx_resources)
        log('Synchronising Intervention Types')
        synchronise_resources(transifex_load, InterventionType.tx_resources)
        log('Synchronising Activity Categories')
        synchronise_resources(transifex_load, ActivityCategory.tx_resources)
        log('Synchronising Intervention Type Groups')
        synchronise_resources(transifex_load, InterventionTypeGroup.tx_resources)
        log('Synchronising Programme Types')
        synchronise_resources(transifex_load, ProgrammeType.tx_resources)
        log('Synchronising Help Pages')
        synchronise_resources(transifex_load, HelpPage.tx_resources)
        log('Synchronising Case Studies')
        synchronise_resources(transifex_load, CaseStudy.tx_resources)
        log('Synchronising Transport Types')
        synchronise_resources(transifex_load, TransportSurvey::TransportType.tx_resources)
        log('Synchronising Alert Type Rating Content Versions')
        synchronise_resources(transifex_load, AlertTypeRatingContentVersion.tx_resources)
        log('Synchronising Equivalence Type Content Versions')
        synchronise_resources(transifex_load, EquivalenceTypeContentVersion.tx_resources)
        log('Synchronising Consent Statements')
        synchronise_resources(transifex_load, ConsentStatement.tx_resources)
        log('Synchronising Comparison Reports')
        synchronise_resources(transifex_load, Comparison::Report.tx_resources)
        log('Synchronising Comparison Footnotes')
        synchronise_resources(transifex_load, Comparison::Footnote.tx_resources)
        log('Synchronising Comparison Report Groups')
        synchronise_resources(transifex_load, Comparison::ReportGroup.tx_resources)
        log('Synchronising Advice Pages')
        synchronise_resources(transifex_load, AdvicePage.tx_resources)
        log('Synchronising Scoreboards')
        synchronise_resources(transifex_load, Scoreboard.tx_resources)
        log('Synchronising Testimonials')
        synchronise_resources(transifex_load, Testimonial.tx_resources)
        log('Synchronising Cms:Category')
        synchronise_resources(transifex_load, ::Cms::Category.tx_resources)
        log('Synchronising Cms:Page')
        synchronise_resources(transifex_load, ::Cms::Page.tx_resources)
        log('Synchronising Cms:Section')
        synchronise_resources(transifex_load, ::Cms::Section.tx_resources)
      rescue => error
        # ensure all errors are caught and logged
        log_error(transifex_load, error)
      end
      transifex_load.update!(status: :done)
    end

    private

    # synchronise a list of individual resources
    def synchronise_resources(transifex_load, tx_serialisable_resources)
      counter = OpenStruct.new(total_pulled: 0, total_pushed: 0)
      tx_serialisable_resources.each do |tx_serialisable|
        process_tx_serialisable(transifex_load, tx_serialisable, counter) if tx_serialisable.has_content?
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
        if @full_sync
          counter.total_pushed += 1 if synchroniser.push
        end
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

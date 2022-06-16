module Transifex
  #Synchroniser that is suitable for use with 'document' / 'resource' oriented
  #records, e.g. activity types
  #
  #Creates and maintains a resource in transifex for the specific active record
  #instance
  class Synchroniser
    def initialize(tx_serialisable)
      @tx_serialisable = tx_serialisable
    end

    def synchronise
      pull
      push
    end

    def pull
      #TODO: should only be if reviews_completed
      if created_in_transifex? && (last_pulled.nil? || translations_updated_since_last_pull?)
        data = transifex_service.pull(@tx_serialisable.slug, :cy)
        #TODO
        @tx_serialisable.tx_update(data, :cy)
      end
    end

    def push
      unless created_in_transifex?
        transifex_service.create_resource(@tx_serialisable.slug, @tx_serialisable.tx_categories)
      end
      if last_pushed.nil? || updated_since_last_pushed?
        transifex_service.push(@tx_serialisable.slug, @tx_serialisable.tx_serialise)
      end
    end

    #Has the resource been created in Transifex?
    def created_in_transifex?
      created_in_transifex.present?
    end

    #Date when created in transifex
    def created_in_transifex
      transifex_status ? transifex_status.tx_created_at : nil
    end

    #Date last pushed
    def last_pushed
      transifex_status ? transifex_status.tx_last_push : nil
    end

    #Date last pulled
    def last_pulled
      transifex_status ? transifex_status.tx_last_pull : nil
    end

    #Have the translations been completed and fully reviewed?
    def reviews_completed?
      return transifex_service.reviews_completed?(@tx_serialisable.slug)
    end

    #Has the model been updated since it was last pushed?
    def updated_since_last_pushed?
      return @tx_serialisable.updated_at > last_pushed
    end

    #Has the resource been updated in Transifex since it was last pulled?
    def translations_updated_since_last_pull?
      return transifex_service.last_reviewed(@tx_serialisable.slug) > last_pulled
    end

    private

    def transifex_service
      @transifex_service || Transifex::Service.new
    end

    def transifex_status
      @tx_serialisable.tx_status
    end
  end
end

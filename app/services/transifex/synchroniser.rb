module Transifex
  # Synchroniser that is suitable for use with 'document' / 'resource' oriented
  # records, e.g. activity types
  #
  # Creates and maintains a resource in transifex for the specific active record
  # instance
  class Synchroniser
    def initialize(tx_serialisable, locale)
      @tx_serialisable = tx_serialisable
      @locale = locale
    end

    def pull
      if created_in_transifex? && reviews_completed? && (last_pulled.nil? || translations_updated_since_last_pull?)
        data = transifex_service.pull(@tx_serialisable.tx_slug, @locale)
        # TODO
        @tx_serialisable.tx_update(data, @locale)
        update_timestamp(:tx_last_pull)
        return true
      end
      false
    end

    def push
      unless created_in_transifex?
        transifex_service.create_resource(@tx_serialisable.tx_name, @tx_serialisable.tx_slug, @tx_serialisable.tx_categories)
      end
      if last_pushed.nil? || updated_since_last_pushed?
        transifex_service.push(@tx_serialisable.tx_slug, @tx_serialisable.tx_serialise)
        update_timestamp(:tx_last_push)
        return true
      end
      return false
    end

    # Has the resource been created in Transifex?
    def created_in_transifex?
      transifex_service.created_in_transifex?(@tx_serialisable.tx_slug)
    end

    # Date last pushed
    def last_pushed
      transifex_status ? transifex_status.tx_last_push : nil
    end

    # Date last pulled
    def last_pulled
      transifex_status ? transifex_status.tx_last_pull : nil
    end

    # Have the translations been completed and fully reviewed?
    def reviews_completed?
      return transifex_service.reviews_completed?(@tx_serialisable.tx_slug, @locale)
    end

    # Has the model been updated since it was last pushed?
    def updated_since_last_pushed?
      # If we've just done a pull then we don't want to trigger an update, as all
      # that's happened is the translated fields have been updated.
      # So check if the update is after the pull timestamp AND since we last pushed
      if last_pulled.present?
        return @tx_serialisable.updated_at > last_pulled && @tx_serialisable.updated_at > last_pushed
      else
        # just check the timestamp
        return @tx_serialisable.updated_at > last_pushed
      end
    end

    # Has the resource been updated in Transifex since it was last pulled?
    def translations_updated_since_last_pull?
      last_reviewed = transifex_service.last_reviewed(@tx_serialisable.tx_slug, @locale)
      if last_pulled
        last_reviewed > last_pulled
      else
        last_reviewed.present?
      end
    end

    private

    def transifex_service
      @transifex_service || Transifex::Service.new
    end

    def transifex_status
      @tx_serialisable.tx_status
    end

    def update_timestamp(field)
      status = transifex_status
      if status.nil?
        status = TransifexStatus.create_for!(@tx_serialisable)
      end
      status.update_attribute(field, Time.zone.now)
    end
  end
end

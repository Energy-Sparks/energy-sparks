module Events
  class ListEvents
    def initialize(org_id = ENV['EVENTBRITE_ORG_ID'], eventbrite_api_token = ENV['EVENTBRITE_API_TOKEN'])
      @org_id = org_id
      @eventbrite_api_token = eventbrite_api_token
    end

    def events_without_images
      @events.reject { |event| event.image_url.present? }
    end

    # Returns an arry of EventBriteSDK::OrgEvent objects
    def fetch
      events ||= []
      query.each do |eventbrite_event|
        events << Events::Event.new(eventbrite_event)
      end
      return events
    rescue => e
      Rails.logger.error "Exception fetching Eventbrite events : #{e.class} #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      Rollbar.error(e)
      return []
    end

    def events
      @events ||= fetch
    end

    private

    # The EventBrite Ruby SDK isn't quite tracking the live API. The intended
    # approach is to do somethin like:
    # 1. retrieve the user: EventbriteSDK::User.retrieve(id: 'me')
    # 2. then find the organisation that the user is part of
    # 3. and from the organisation, its events
    #
    # But due to a bug in the library we are directly fetching the events for
    # a specific org id, which has to be configured. This does reduce number
    # of API calls, but also requires extra configuration.
    #
    # Note: this only fetches first 50 events, would need to add paging to
    # fetch all. But 50 events seems more than enough for the /training page
    #
    # Returns an EventBriteSDK::ResourceList
    def query
      # expand: "ticket_availability" to get info whether sold out
      # limit to live only events, most recent first
      EventbriteSDK::Organization.new(id: @org_id).events.retrieve(
        api_token: @eventbrite_api_token,
        query: { expand: 'ticket_availability', status: 'live', order_by: :start_asc }
      )
    end
  end
end

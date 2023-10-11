module Events
  class Event
    attr_reader :date, :name, :url

    # create with an EventbriteSDK::Event object
    def initialize(eventbrite)
      @name = eventbrite.name.html
      @date = DateTime.parse(eventbrite.start.local)
      @url = eventbrite.url
      @sold_out = false
      @sold_out = eventbrite.ticket_availability.is_sold_out if eventbrite.ticket_availability.present?
    end

    def sold_out?
      @sold_out
    end
  end
end

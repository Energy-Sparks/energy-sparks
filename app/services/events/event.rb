module Events
  class Event
    attr_reader :date, :name, :url

    #create with an EventbriteSDK::Event object
    def initialize(eventbrite)
      @name = eventbrite.name.html
      @date = Date.parse(eventbrite.start.local)
      @url = eventbrite.url
      @sold_out = false
      if eventbrite.ticket_availability.present?
        @sold_out = eventbrite.ticket_availability.is_sold_out
      end
    end

    def sold_out?
      @sold_out
    end
  end
end

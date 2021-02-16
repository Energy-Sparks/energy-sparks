require 'rails_helper'

module Events
  describe Event do

    let(:org_event) {
      EventbriteSDK::OrgEvent.new(
        id: 123,
        url: "https://example/org/123",
        name: {
          text: "text name",
          html: "html name"
        },
        start: {
          timezone: "Europe/London",
          local: "2021-03-23T16:00:00",
          utc: "2021-03-23T16:00:00Z"
        },
        ticket_availability: {
          is_sold_out: true
        }
      )
    }

    it "initialises properly" do
      event = Events::Event.new(org_event)
      expect( event.name ).to eql("html name")
      expect( event.date ).to eql( Date.parse("2021-03-23") )
      expect( event.url ).to eql("https://example/org/123")
      expect( event.sold_out? ).to eql(true)
    end
  end
end

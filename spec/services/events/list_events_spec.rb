require 'rails_helper'

module Events
  describe ListEvents do

    let(:org_id)   { "4444" }
    let(:url_base) { "organizations/#{org_id}/events" }
    let(:api_token)    { "secret-token"}
    let(:query)    { { expand: "ticket_availability", status: 'live', order_by: :start_asc } }
    let(:response) { JSON.load( File.new( File.join( fixture_path, "events/events.json") ) ) }

    it "handles API errors" do
      expect(EventbriteSDK).to receive(:get).with(api_token: api_token, query: query, url: url_base) do
        raise
      end
      events = Events::ListEvents.new(org_id, api_token).perform
      expect( events ).to eql []
    end

    it "calls the API correctly" do
      expect(EventbriteSDK).to receive(:get).with(api_token: api_token, query: query, url: url_base) do
        response
      end
      events = Events::ListEvents.new(org_id, api_token).perform
      expect( events.size ).to eql 4
    end

    it "converts to local objects" do
      expect(EventbriteSDK).to receive(:get).with(api_token: api_token, query: query, url: url_base) do
        response
      end
      events = Events::ListEvents.new(org_id, api_token).perform
      expect( events[0].name ).to eql("Energy Sparks induction session")
      expect( events[0].url ).to eql("https://www.eventbrite.co.uk/e/energy-sparks-induction-session-tickets-138294742297")
      expect( events[0].sold_out?).to eql(false)
      expect( events[0].date ).to eql(Date.parse("2021-03-02T16:00:00"))
      expect( events[3].date).to eql(Date.parse("2021-06-08T16:00:00"))
    end

  end
end

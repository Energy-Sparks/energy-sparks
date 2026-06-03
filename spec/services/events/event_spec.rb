require 'rails_helper'

module Events
  describe Event do
    let(:org_event) do
      EventbriteSDK::OrgEvent.new(
        id: 123,
        url: 'https://example/org/123',
        name: {
          text: 'text name',
          html: 'html name'
        },
        summary: 'Summary text',
        logo: {
          url: 'https://example.org/image'
        },
        start: {
          timezone: 'Europe/London',
          local: '2021-03-23T16:00:00',
          utc: '2021-03-23T16:00:00Z'
        },
        ticket_availability: {
          is_sold_out: true
        }
      )
    end

    it 'initialises properly' do
      event = Events::Event.new(org_event)
      expect(event.name).to eql('html name')
      expect(event.summary).to eq 'Summary text'
      expect(event.date).to eql(DateTime.parse('2021-03-23T16:00:00'))
      expect(event.url).to eql('https://example/org/123')
      expect(event.image_url).to eql('https://example.org/image')
      expect(event.sold_out?).to be(true)
    end
  end
end

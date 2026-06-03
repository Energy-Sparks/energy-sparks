require 'rails_helper'

module Events
  describe ListEvents do
    let(:org_id)      { '4444' }
    let(:api_token)   { 'secret-token' }
    let(:list_events) { ListEvents.new(org_id, api_token) }

    describe '#events' do
      subject(:events) { list_events.events }

      let(:api_params) do
        { api_token: api_token,
          query: { expand: 'ticket_availability', status: 'live', order_by: :start_asc },
          url: "organizations/#{org_id}/events" }
      end

      context 'when the API raises an error' do
        before do
          allow(EventbriteSDK).to receive(:get).with(api_params).and_raise('API error')
          allow(Rails.logger).to receive(:error)
        end

        it 'returns an empty array' do
          expect(events).to eql []
        end
      end

      context 'when the API returns events' do
        before do
          response = JSON.parse(File.read(File.join(fixture_paths.first, 'events/events.json')))
          allow(EventbriteSDK).to receive(:get).with(api_params).and_return(response)
        end

        it { expect(events).to be_a(Array) }
        it { expect(events.size).to eq 4 }

        it 'converts first event into a local object' do
          expect(events[0].name).to eql('Energy Sparks induction session')
          expect(events[0].summary).to eql('An online induction to help you get started reducing energy consumption with Energy Sparks.')
          expect(events[0].date).to eql(DateTime.parse('2021-03-02T16:00:00'))
          expect(events[0].url).to eql('https://www.eventbrite.co.uk/e/energy-sparks-induction-session-tickets-138294742297')
          expect(events[0].image_url).to eql('https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F113596237%2F481005514167%2F1%2Foriginal.20201005-092822?h=200&w=450&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C161%2C1086%2C543&s=1279466ca350155300d6b315d128f3d9')
          expect(events[0].sold_out?).to be(false)
        end

        it 'converts last event into a local object' do
          expect(events[3].name).to eql('Another Energy Sparks induction session')
          expect(events[3].summary).to eql('Another online induction to help you get started reducing energy consumption with Energy Sparks.')
          expect(events[3].date).to eql(DateTime.parse('2021-06-08T16:00:00'))
          expect(events[3].url).to eql('https://www.eventbrite.co.uk/e/energy-sparks-induction-session-tickets-141010286563')
          expect(events[3].image_url).to eql('https://img.evbuc.com/https%3A%2F%2Fcdn.evbuc.com%2Fimages%2F113596237%2F481005514167%2F1%2Foriginal.20201005-092822?h=200&w=450&auto=format%2Ccompress&q=75&sharp=10&rect=0%2C161%2C1086%2C543&s=1279466ca350155300d6b315d128f3d9')
          expect(events[3].sold_out?).to be(true)
        end
      end
    end
  end
end

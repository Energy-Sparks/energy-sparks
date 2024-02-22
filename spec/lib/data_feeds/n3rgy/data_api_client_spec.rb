# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::N3rgy::DataApiClient do
  subject(:client) do
    described_class.new(api_key: api_key, base_url: base_url, connection: connection)
  end

  let(:stubs)       { Faraday::Adapter::Test::Stubs.new }
  let(:connection)  { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:base_url)    { 'https://api.example.org' }
  let(:api_key)     { 'token' }

  after do
    Faraday.default_connection = nil
  end

  shared_examples 'a stubbed call that errors' do
    it 'handles the error' do
      expect do
        client.send(method, *params)
      end.to raise_error(error,
        message)
      stubs.verify_stubbed_calls
    end
  end

  describe '#list_consented_meters' do
    context 'with a successful response' do
      let(:response) do
        {
          "resource": '/',
          "responseTimestamp": '2020-11-10T17:07:01.580Z',
          "startAt": 0,
          "maxResults": 100,
          "total": 1,
          "entries": [
            '1230267891094'
          ]
        }
      end

      it 'returns the results'
    end
  end
end

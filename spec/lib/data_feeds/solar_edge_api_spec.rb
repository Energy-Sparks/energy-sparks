# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::SolarEdgeApi do
  let(:success)     { true }
  let(:status)      { 200 }
  let(:api_key)     { 'fake' }
  let(:client)      { described_class.new(api_key) }

  let(:response)    { instance_double(Faraday::Response, success?: success, status:, body: body.to_json) }
  let(:headers)     { { Accept: 'application/json' } }

  before do
    allow(Faraday).to receive(:get).with(expected_url, expected_params, headers).and_return(response)
  end

  # minimal test of HTTP response handling behaviour
  describe '#site_details' do
    let(:expected_url) { "#{DataFeeds::SolarEdgeApi::BASE_URL}/sites/list" }
    let(:expected_params) { { api_key: } }

    context 'with success' do
      let(:body) do
        {
          'sites' => {
            'count' => 1,
            'site' => {
              'id' => '1234'
            }
          }
        }
      end

      it 'returns data' do
        expect(client.site_details).to eql body
      end
    end

    context 'with 403 error' do
      let(:success)     { false }
      let(:status)      { 403 }
      let(:response)    { instance_double(Faraday::Response, success?: success, status:, body: body.to_json) }

      let(:body) do
        {
          String: 'Invalid token'
        }
      end

      it 'throws exception' do
        expect do
          client.site_details
        end.to raise_error(DataFeeds::SolarEdgeApi::NotAllowed)
      end
    end

    context 'with other error' do
      let(:status)      { 500 }
      let(:success)     { false }
      let(:response)    { instance_double(Faraday::Response, success?: success, status:, body:) }
      let(:body)        { '<html>Some HTML</html>' }

      it 'throws exception' do
        expect do
          client.site_details
        end.to raise_error(DataFeeds::SolarEdgeApi::ApiFailure)
      end
    end
  end
end

# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::SolarEdge::Api do
  let(:status) { 200 }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }

  around do |example|
    ClimateControl.modify SOLAR_EDGE_CLIENT_ID: 'solar_edge_client_id', SOLAR_EDGE_CLIENT_SECRET: 'solar_edge_secret' do
      example.run
    end
  end

  after do
    Faraday.default_connection = nil
    stubs.verify_stubbed_calls
  end

  describe '.authorize_url' do
    it 'builds url with client and external ids' do
      expect(described_class.authorize_url(1234)).to eq(
        'https://connect.solaredge.com/authorize?client_id=solar_edge_client_id&external_id=1234'
      )
    end
  end

  describe '#retrieve_access_token' do
    context 'with a success' do
      let(:expected_response) do
        {
          'access_token' => '2YotnFZFEjr1zCsicMWpAA',
          'token_type' => 'Bearer',
          'expires_in' => 7200,
          'refresh_token' => 'tGzv3JOkF0XG5Qx2TlKWIA'
        }
      end

      it 'returns the parsed response' do
        stubs.post('/v2/oauth2/token') do |env|
          expect(env.body).to eq({
                                   'client_id' => 'solar_edge_client_id',
                                   'client_secret' => 'solar_edge_secret',
                                   'grant_type' => 'authorization_code',
                                   'code' => 'TEMPORARY_TOKEN'
                                 })
          [200, { 'Content-Type': 'application/json' }, expected_response.to_json]
        end
        response = described_class.new(stubs:).retrieve_access_token('TEMPORARY_TOKEN')
        expect(response).to eq(expected_response)
      end
    end

    context 'with an token exchange error' do
      it 'throws an exception' do
        stubs.post('/v2/oauth2/token') do
          [400, { 'Content-Type': 'application/json' }, '']
        end
        expect { described_class.new(stubs:).retrieve_access_token('X') }.to raise_error(Faraday::Error)
      end
    end
  end

  describe '#refresh_access_token' do
    context 'with a success' do
      let(:expected_response) do
        {
          'access_token' => 'aNewAccessTokenValueXyz',
          'token_type' => 'Bearer',
          'expires_in' => 7200,
          'refresh_token' => 'aNewRefreshTokenValueAbc'
        }
      end

      it 'returns the parsed response' do
        stubs.post('/v2/oauth2/token') do |env|
          expect(env.body).to eq({
                                   'client_id' => 'solar_edge_client_id',
                                   'client_secret' => 'solar_edge_secret',
                                   'grant_type' => 'refresh_token',
                                   'refresh_token' => 'tGzv3JOkF0XG5Qx2TlKWIA'
                                 })
          [200, { 'Content-Type': 'application/json' }, expected_response.to_json]
        end
        response = described_class.new(stubs:).refresh_access_token('tGzv3JOkF0XG5Qx2TlKWIA')
        expect(response).to eq(expected_response)
      end
    end
  end
end

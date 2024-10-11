# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::GeoApi do
  let(:success)     { true }
  let(:status)      { 200 }
  let(:response)    { instance_double(Faraday::Response, success?: success, status:, body: body.to_json) }

  describe '#login' do
    let(:expected_headers)  { { Accept: 'application/json', 'Content-Type': 'application/json' } }
    let(:expected_url)      { "#{DataFeeds::GeoApi::BASE_URL}/userapi/account/login" }
    let(:expected_payload)  { { emailAddress: username, password: }.to_json }
    let(:body)              { { token: 'abc123' } }

    context 'with credentials' do
      let(:username) { 'myUser' }
      let(:password) { 'myPass' }

      before do
        allow(Faraday).to receive(:post).with(expected_url, expected_payload, expected_headers).and_return(response)
      end

      it 'calls the login endpoint and returns token' do
        token = described_class.new(username:, password:).login
        expect(token).to eq('abc123')
      end

      context 'with error response' do
        let(:status)      { 401 }

        it 'raises error' do
          expect do
            described_class.new(username:, password:).login
          end.to raise_error(DataFeeds::GeoApi::NotAuthorised)
        end
      end
    end

    context 'with missing credential' do
      let(:username) { 'myUser' }
      let(:password) { '' }

      it 'raises error' do
        expect do
          described_class.new(username:, password:).login
        end.to raise_error(DataFeeds::GeoApi::ApiFailure)
      end
    end
  end

  describe '#trigger_fast_update' do
    let(:expected_url) do
      "#{DataFeeds::GeoApi::BASE_URL}/supportapi/system/trigger-fastupdate/#{system_id}"
    end
    let(:expected_headers) do
      { Accept: 'application/json', 'Content-Type': 'application/json', Authorization: "Bearer #{token}" }
    end
    let(:system_id)         { 'xyz987' }
    let(:body)              { '' }

    context 'with token' do
      let(:token) { 'abc123' }

      before do
        allow(Faraday).to receive(:get).with(expected_url, nil, expected_headers).and_return(response)
      end

      it 'calls the trigger fast update' do
        ret = described_class.new(token:).trigger_fast_update(system_id)
        expect(ret).to eq('')
      end
    end

    context 'with missing token' do
      let(:token) { nil }

      it 'raises error' do
        expect do
          described_class.new(token:).trigger_fast_update(system_id)
        end.to raise_error DataFeeds::GeoApi::ApiFailure
      end
    end
  end
end

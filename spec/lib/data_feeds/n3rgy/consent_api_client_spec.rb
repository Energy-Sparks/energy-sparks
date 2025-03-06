# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::N3rgy::ConsentApiClient do
  subject(:client) do
    described_class.new(api_key: api_key, base_url: base_url, connection: connection)
  end

  let(:stubs)       { Faraday::Adapter::Test::Stubs.new }
  let(:connection)  { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:base_url)    { 'https://api.example.org' }
  let(:api_key)     { 'token' }

  let(:mpxn) { '1234567891000' }

  after do
    Faraday.default_connection = nil
  end

  shared_examples 'a successfully handled error' do
    it 'by throwing the expected exception' do
      expect do
        client.send(method, *params)
      end.to raise_error(DataFeeds::N3rgy::ConsentFailure, message)
      stubs.verify_stubbed_calls
    end
  end

  describe '#add_trusted_consent' do
    let(:ref)     { 'some random guid' }

    context 'when API returns success' do
      let(:response) do
        {
          "resource": 'consents/add-trusted-consent',
          "responseTimestamp": '2020-11-10T17:07:01.580Z',
          "mpxn": '1234567891000',
          "status": {
            "code": 'OK',
            "message": 'Request to register the consent was successful.'
          }
        }
      end

      it 'returns true' do
        stubs.post('/consents/add-trusted-consent') do |_env|
          [200, {}, response.to_json]
        end
        expect(client.add_trusted_consent(mpxn, ref)).to eq(true)
        stubs.verify_stubbed_calls
      end
    end

    context 'when API returns an error' do
      let(:response) do
        {
          "errors": [
            {
              "code": 400,
              "message": 'Unsuccessful trusted consent to property'
            }
          ]
        }
      end

      it_behaves_like 'a successfully handled error' do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stubs|
            stubs.post('/consents/add-trusted-consent') do |_env|
              [400, {}, response.to_json]
            end
          end
        end
        let(:method) { :add_trusted_consent }
        let(:params) { [mpxn, ref] }
        let(:message) { 'Unsuccessful trusted consent to property' }
      end
    end

    context 'when API returns an authorization error' do
      let(:response) do
        {
          "message": 'User is not authorized to access this resource with an explicit deny.'
        }
      end

      it_behaves_like 'a successfully handled error' do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stubs|
            stubs.post('/consents/add-trusted-consent') do |_env|
              [403, {}, response.to_json]
            end
          end
        end
        let(:method) { :add_trusted_consent }
        let(:params) { [mpxn, ref] }
        let(:message) { 'User is not authorized to access this resource with an explicit deny.' }
      end
    end
  end

  describe '#withdraw_consent' do
    context 'when success' do
      let(:response) do
        {
          "resource": 'consents/withdraw-consent/1234567891000',
          "responseTimestamp": '2020-11-10T17:07:01.580Z',
          "status": {
            "code": 'OK',
            "message": 'Request to withdraw the consent was successful.'
          }
        }
      end

      it 'returns true' do
        stubs.delete('/consents/withdraw-consent/1234567891000') do |_env|
          [200, {}, response.to_json]
        end
        expect(client.withdraw_consent(mpxn)).to be true
        stubs.verify_stubbed_calls
      end
    end

    context 'when failed' do
      let(:response) do
        {
          "errors": [
            {
              "code": 400,
              "message": 'message'
            }
          ]
        }
      end

      it_behaves_like 'a successfully handled error' do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stubs|
            stubs.delete('/consents/withdraw-consent/1234567891000') do |_env|
              [400, {}, response.to_json]
            end
          end
        end
        let(:method) { :withdraw_consent }
        let(:params) { [mpxn] }
        let(:message) { 'message' }
      end
    end

    context 'when authorisation error' do
      let(:response) do
        {
          "message": 'User is not authorized to access this resource with an explicit deny.'
        }
      end

      it_behaves_like 'a successfully handled error' do
        let(:stubs) do
          Faraday::Adapter::Test::Stubs.new do |stubs|
            stubs.delete('/consents/withdraw-consent/1234567891000') do |_env|
              [403, {}, response.to_json]
            end
          end
        end
        let(:method) { :withdraw_consent }
        let(:params) { [mpxn] }
        let(:message) { 'User is not authorized to access this resource with an explicit deny.' }
      end
    end
  end
end

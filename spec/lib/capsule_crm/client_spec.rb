# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe CapsuleCrm::Client do
  subject(:client) do
    described_class.new(api_key: api_key, connection: connection)
  end

  let(:stubs)       { Faraday::Adapter::Test::Stubs.new }
  let(:connection)  { Faraday.new { |b| b.adapter(:test, stubs) } }
  let(:api_key)     { 'bearer_token' }

  after do
    Faraday.default_connection = nil
  end

  shared_examples 'a successfully handled error' do
    it 'by throwing the expected exception' do
      expect do
        client.send(method, *params)
      end.to raise_error(expected_error, expected_message)
      stubs.verify_stubbed_calls
    end
  end

  describe '#create_party' do
    context 'when API returns an error' do
      let(:method) { :create_party }
      let(:party)  { {} }
      let(:message) { 'Expected message' }
      let(:response) do
        {
          message: message
        }
      end
      let(:url) { 'https://api.capsulecrm.com/api/v2/parties' }

      context 'with authorisation error' do
        it_behaves_like 'a successfully handled error' do
          let(:stubs) do
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post(url) do |_env|
                [401, party, response.to_json]
              end
            end
          end
          let(:params) { [party] }
          let(:expected_error) { CapsuleCrm::NotAuthorised }
          let(:expected_message) { message }
        end
      end

      context 'with permission error' do
        it_behaves_like 'a successfully handled error' do
          let(:stubs) do
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post(url) do |_env|
                [403, party, response.to_json]
              end
            end
          end
          let(:params) { [party] }
          let(:expected_error) { CapsuleCrm::NotAllowed }
          let(:expected_message) { message }
        end
      end

      context 'with bad request' do
        it_behaves_like 'a successfully handled error' do
          let(:stubs) do
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post(url) do |_env|
                [400, party, response.to_json]
              end
            end
          end
          let(:params) { [party] }
          let(:expected_error) { CapsuleCrm::BadRequest }
          let(:expected_message) { message }
        end
      end

      context 'with validation failure' do
        let(:response) do
          {
            message: message,
            errors: [
              { message: 'name is required',
                resource: 'party',
                field: 'name' }
            ]
          }
        end

        it_behaves_like 'a successfully handled error' do
          let(:stubs) do
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post(url) do |_env|
                [422, party, response.to_json]
              end
            end
          end
          let(:params) { [party] }
          let(:expected_error) { CapsuleCrm::ValidationFailed }
          let(:expected_message) { 'Expected message, name is required' }
        end
      end

      context 'with server error' do
        it_behaves_like 'a successfully handled error' do
          let(:stubs) do
            Faraday::Adapter::Test::Stubs.new do |stubs|
              stubs.post(url) do |_env|
                [500, party, response.to_json]
              end
            end
          end
          let(:params) { [party] }
          let(:expected_error) { CapsuleCrm::ApiFailure }
          let(:expected_message) { message }
        end
      end
    end
  end
end

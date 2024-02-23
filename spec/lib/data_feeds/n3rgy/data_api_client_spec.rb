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

  shared_examples 'a successfully handled error' do
    it 'by throwing the expected exception' do
      expect do
        client.send(method, *params)
      end.to raise_error(error, message)
      stubs.verify_stubbed_calls
    end
  end

  describe '#list_consented_meters' do
    context 'with a successful request' do
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

      it 'returns the response' do
        stubs.get('/?startAt=0&maxResults=100') do |_env|
          [200, {}, response.to_json]
        end
        api_response = client.list_consented_meters
        expect(api_response).to eq(response.with_indifferent_access)
        stubs.verify_stubbed_calls
      end

      context 'with passed parameters' do
        it 'queries the right url' do
          stubs.get('/?startAt=5&maxResults=10') do |_env|
            [200, {}, response.to_json]
          end
          client.list_consented_meters(start_at: 5, max_results: 10)
          stubs.verify_stubbed_calls
        end
      end
    end
  end

  describe '#find_mpxn' do
    let(:response) do
      {
        "resource": '/find-mpxn/1234567891002',
        "responseTimestamp": '2024-02-23T11:03:23.040Z',
        "mpxn": '1234567891002',
        "deviceType": 'ESME',
        "deviceId": '02-00-00-00-00-00-02-01',
        "deviceStatus": 'COMMISSIONED',
        "deviceManufacturer": '123E',
        "deviceModel": 'Model-XYZ',
        "propertyFilter": {
          "postCode": 'C2A 2EE',
          "addressIdentifier": '22A, SOMEWHERE'
        }
      }
    end

    it 'returns the response' do
      stubs.get('/find-mpxn/1234567891002') do |_env|
        [200, {}, response.to_json]
      end
      api_response = client.find_mpxn('1234567891002')
      expect(api_response).to eq(response.with_indifferent_access)
      stubs.verify_stubbed_calls
    end
  end

  describe '#utilities' do
    let(:response) do
      {
        "resource": '/mpxn/1234567891012',
        "responseTimestamp": '2022-04-10T17:07:01.580Z',
        "entries": "['electricity', 'gas']"
      }
    end

    it 'returns the response' do
      stubs.get('/mpxn/1234567891012') do |_env|
        [200, {}, response.to_json]
      end
      api_response = client.utilities('1234567891012')
      expect(api_response).to eq(response.with_indifferent_access)
      stubs.verify_stubbed_calls
    end
  end

  describe '#reading_types' do
    let(:response) do
      {
        "resource": '/mpxn/1234567891002/utility/electricity',
        "responseTimestamp": '2024-02-23T12:36:47.056Z',
        "devices": [
          {
            "deviceId": '02-00-00-00-00-00-02-01',
            "availableDataTypes": %w[
              consumption
              tariff
            ]
          }
        ]
      }
    end

    it 'returns the response' do
      stubs.get('/mpxn/1234567891002/utility/electricity') do |_env|
        [200, {}, response.to_json]
      end
      api_response = client.reading_types('1234567891002', :electricity)
      expect(api_response).to eq(response.with_indifferent_access)
      stubs.verify_stubbed_calls
    end
  end

  describe '#readings' do
    context 'with a successful request' do
      let(:response) { JSON.parse(File.read('spec/fixtures/n3rgy/get-reading-type-consumption.json')) }

      it 'returns the response' do
        stubs.get('/mpxn/1234567891000/utility/electricity/readingtype/consumption?granularity=halfhour&outputFormat=json') do |_env|
          [200, {}, response.to_json]
        end
        api_response = client.readings('1234567891000', :electricity, 'consumption')
        expect(api_response).to eq(response.with_indifferent_access)
        stubs.verify_stubbed_calls
      end

      context 'with date parameters' do
        it 'queries the right url' do
          url = '/mpxn/1234567891000/utility/electricity/readingtype/consumption'
          url = url + '?granularity=halfhour&outputFormat=json&start=202401010000&end=202401020000'
          stubs.get(url) do |_env|
            [200, {}, response.to_json]
          end
          client.readings('1234567891000', :electricity, 'consumption', Date.new(2024, 1, 1), Date.new(2024, 1, 2))
          stubs.verify_stubbed_calls
        end
      end
    end
  end

  describe '#read_inventory' do
    let(:uri) { 'https://read-inventory.data.n3rgy.com/files/767c1f42-9d52-43c1-8909-f61c78aa1916.json' }
    let(:response) do
      {
        "status": 200,
        "uuid": '767c1f42-9d52-43c1-8909-f61c78aa1916',
        "uri": uri
      }
    end

    it 'requests correct url' do
      stubs.post('/read-inventory') do |env|
        expect(env.body).to eql({
          mpxns: ['1100000000024']
        }.to_json)
        [200, {}, response.to_json]
      end
      api_response = client.read_inventory('ESME', mpxns: '1100000000024')
      expect(api_response).to eq(response.with_indifferent_access)
      stubs.verify_stubbed_calls
    end
  end

  describe '#fetch_with_retry' do
    context 'with auth failure' do
      let(:response) { { "message": 'Unauthorized' } }

      it 'raises error' do
        stubs.get('some-inventory-file') do |_env|
          [401, {}, 'no way']
        end
        expect do
          client.fetch_with_retry('some-inventory-file')
        end.to raise_error(DataFeeds::N3rgy::NotAuthorised, 'no way')
        stubs.verify_stubbed_calls
      end
    end

    context 'with retry' do
      context 'when it works' do
        let(:response) { { 'result' => 'your data' } }

        it 'returns contents' do
          stubs.get('some-inventory-file') do |_env|
            [200, {}, response.to_json]
          end
          contents = client.fetch_with_retry('some-inventory-file', 0.1, 3)
          expect(contents).to eq(response)
          stubs.verify_stubbed_calls
        end
      end

      context 'when it fails' do
        it 'retries and then raises error' do
          stubs.get('some-inventory-file') do |_env|
            [403, {}, 'not ready']
          end
          expect do
            client.fetch_with_retry('some-inventory-file', 0.1, 3)
          end.to raise_error(DataFeeds::N3rgy::NotAllowed, 'not ready')
        end
      end
    end
  end
end

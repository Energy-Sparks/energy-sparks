# frozen_string_literal: true

require 'rails_helper'
require 'faraday/adapter/test'

describe DataFeeds::PvLiveApi do
  let(:success)     { true }
  let(:status)      { 200 }
  let(:client)      { described_class.new }

  let(:response)    { instance_double(Faraday::Response, success?: success, status:, body: body.to_json) }

  before do
    allow(Faraday).to receive(:get).with(expected_url, expected_params, {}).and_return(response)
  end

  describe '#gsp_list' do
    let(:expected_url) { "#{DataFeeds::PvLiveApi::BASE_URL}/gsp_list" }
    let(:expected_params) { {} }

    context 'with success' do
      let(:body) do
        {
          data: [
            [
              0,
              'NATIONAL',
              0,
              '_0'
            ]
          ],
          meta: %w[
            gsp_id
            gsp_name
            pes_id
            pes_name
          ]
        }
      end

      it 'returns data' do
        expect(client.gsp_list).to eql body
      end
    end

    context 'with error' do
      # they return a 200 error code with a JSON error document for errors
      let(:status)      { 200 }
      let(:response)    { instance_double(Faraday::Response, success?: success, status:, body: body.to_json) }

      let(:body) do
        {
          error_code: nil,
          error_description: "Unknown url parameter(s): {'XXX'}"
        }
      end

      it 'throws exception' do
        expect do
          client.gsp_list
        end.to raise_error(DataFeeds::PvLiveApi::ApiFailure)
      end
    end

    context 'with 404' do
      let(:status)      { 404 }
      let(:response)    { instance_double(Faraday::Response, success?: success, status:, body:) }
      let(:body)        { '<html>Some HTML</html>' }

      it 'throws exception' do
        expect do
          client.gsp_list
        end.to raise_error(DataFeeds::PvLiveApi::ApiFailure)
      end
    end
  end

  describe '#gsp' do
    let(:expected_url) { "#{DataFeeds::PvLiveApi::BASE_URL}/gsp/0" }
    let(:expected_params) { { data_format: 'json', extra_fields: 'installedcapacity_mwp' } }
    let(:body) do
      {
        data: [
          [
            0,
            '2021-10-11T13:30:00Z',
            4670.0
          ]
        ],
        meta: %w[
          gsp_id
          datetime_gmt
          generation_mw
        ]
      }
    end

    context 'with default params' do
      it 'calls expected url with params and returns the parsed response' do
        expect(client.gsp(0)).to eql body
      end
    end

    context 'with dates' do
      let(:expected_params) do
        { data_format: 'json', extra_fields: 'installedcapacity_mwp', start: '2021-01-01T00:00:00Z',
          end: '2021-01-02T23:59:59Z' }
      end

      it 'calls expected url with params and returns the parsed response' do
        expect(client.gsp(0, Date.new(2021, 0o1, 0o1), Date.new(2021, 0o1, 0o2))).to eql body
      end
    end
  end
end

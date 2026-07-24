# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::PvLiveApi do
  subject(:client) { described_class.new }

  let(:success) { true }
  let(:status) { 200 }
  let(:body) { '' }
  let(:params) { '' }

  before do
    stub_request(:get, "#{expected_url}#{params}").to_return(status:, body: body.to_json,
                                                             headers: { 'content-type': 'application/json' })
  end

  describe '#gsp_list' do
    let(:expected_url) { "#{DataFeeds::PvLiveApi::BASE_URL}/gsp_list" }

    context 'with success' do
      let(:body) do
        { data: [[0, 'NATIONAL', 0, '_0']],
          meta: %w[gsp_id gsp_name pes_id pes_name] }
      end

      it 'returns data' do
        expect(client.gsp_list).to eql body
      end
    end

    context 'with 200 status code and JSON error key' do
      let(:body) { { error_code: nil, error_description: "Unknown url parameter(s): {'XXX'}" } }

      it 'throws an exception' do
        expect { client.gsp_list }.to raise_error(DataFeeds::PvLiveApi::ApiFailure)
      end
    end

    context 'with 404' do
      let(:status) { 404 }

      it 'throws an exception' do
        expect { client.gsp_list }.to raise_error(Faraday::Error)
      end
    end
  end

  describe '#gsp' do
    let(:expected_url) { "#{DataFeeds::PvLiveApi::BASE_URL}/gsp/0" }
    let(:params) { '?extra_field=installedcapacity_mwp' }
    let(:body) do
      { data: [[0, '2021-10-11T13:30:00Z', 4670.0]],
        meta: %w[gsp_id datetime_gmt generation_mw] }
    end

    context 'with default params' do
      it 'calls expected url with params and returns the parsed response' do
        expect(client.gsp(0)).to eql body
      end
    end

    context 'with dates' do
      let(:params) { '?extra_field=installedcapacity_mwp&start=2021-01-01T00:00:00Z&end=2021-01-01T23:59:59Z' }

      it 'calls expected url with params and returns the parsed response' do
        expect(client.gsp(0, Date.new(2021), Date.new(2021))).to eql body
      end
    end
  end
end

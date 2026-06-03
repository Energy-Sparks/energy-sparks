# frozen_string_literal: true

require 'rails_helper'

describe DataFeeds::MeteoStatApi do
  let(:status) { 200 }
  let(:stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:api) { described_class.new('123', stubs) }

  after do
    Faraday.default_connection = nil
    stubs.verify_stubbed_calls
  end

  context 'when rate limiting' do
    it 'is limited' do
      add_stub(200)
      expect { 10.times { api.find_station('xyz') } }.to change(Time, :now).by_at_least(2)
    end
  end

  context 'when response is 200' do
    it 'returns parsed data' do
      add_stub(200)
      expect(api.find_station('xyz')).to eq({ 'a' => '1' })
    end
  end

  context 'when response is http error' do
    it 'tries once only then raise error' do
      add_stub(404)
      expect { api.find_station('xyz') }.to raise_error(DataFeeds::MeteoStatApi::HttpError)
    end
  end

  context 'when response is 429' do
    it 'retries and returns parsed data' do
      add_stub(429)
      add_stub(200)
      expect(api.find_station('xyz')).to eq({ 'a' => '1' })
    end
  end

  def add_stub(status_code)
    stubs.get('/stations/meta') { [status_code, { 'Content-Type': 'application/json' }, '{"a": "1"}'] }
  end
end

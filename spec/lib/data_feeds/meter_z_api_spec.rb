# frozen_string_literal: true

require 'rails_helper'

RSpec.describe DataFeeds::MeterZApi do
  subject(:client) { described_class.new(api_key) }

  let(:api_key) { 'secret-api-key' }
  let(:organisation_id) { 'org-1' }
  let(:site_id) { 'site-1' }
  let(:meter_id) { 'meter-1' }

  describe '#readings' do
    def stub_readings(readings, query: {}, body: {})
      stub_request(:get, "https://api.meterz.co.uk/v1/organisations/#{organisation_id}/sites/#{site_id}" \
                         "/meters/#{meter_id}/readings")
        .with(headers: { 'x-api-key' => api_key },
              query: { 'start_datetime' => Date.tomorrow.iso8601,
                       'items_per_page' => '1000' }.merge(query.stringify_keys).compact)
        .to_return(body: { readings:, more_items_to_return: false }.merge(body).compact.to_json,
                   headers: { 'Content-Type' => 'application/json' })
    end

    context 'when start is nil' do
      before do
        travel_to(Time.zone.local(2026))
        stub_readings([1])
      end

      it 'requests readings from tomorrow and returns them' do
        expect(client.readings(organisation_id, site_id, meter_id, nil)).to eq([1])
      end
    end

    context 'when start is provided' do
      let(:start) { DateTime.new(2026) }

      before do
        stub_readings([1], query: { end_datetime: start.iso8601, start_datetime: nil })
      end

      it 'passes end_datetime' do
        expect(client.readings(organisation_id, site_id, meter_id, start)).to eq([1])
      end
    end

    context 'when the API is paginated' do
      before do
        stub_readings([1, 2], body: { more_items_to_return: true, last_evaluated_key: '2' })
        stub_readings([3], query: { last_evaluated_key: '2' })
      end

      it 'retrieves every page' do
        expect(client.readings(organisation_id, site_id, meter_id, nil)).to eq([1, 2, 3])
      end
    end
  end
end

# frozen_string_literal: true

module Meters
  # Provides a set of useful methods for interacting with the n3rgy API to fetch
  # information about meters
  class N3rgyMeteringService
    RETRY_INTERVAL = 2
    MAX_RETRIES = 4

    def initialize(meter)
      @meter = meter
      @api_client = DataFeeds::N3rgy::DataApiClient.production_client
    end

    def self.consented_meters
      api_client = DataFeeds::N3rgy::DataApiClient.production_client
      response = api_client.list_consented_meters
      response['entries']
    rescue StandardError => e
      Rollbar.error(e)
      []
    end

    def status
      @api_client.find_mpxn(@meter.mpan_mprn)
      :available
    rescue DataFeeds::N3rgy::NotFound
      :unknown
    rescue DataFeeds::N3rgy::NotAllowed
      :consent_required
    end

    def available?
      @api_client.find_mpxn(@meter.mpan_mprn)
      true
    rescue StandardError
      false
    end

    def type
      device_id = @api_client.find_mpxn(@meter.mpan_mprn)['deviceId']
      device_id&.split('-')&.count == 8 ? :smets2 : :other
    rescue StandardError
      :no
    end

    def consented?
      return unless available?

      # need to be consented to call this successfully
      @api_client.utilities(@meter.mpan_mprn)
      true
    rescue StandardError
      false
    end

    def find_mpxn
      @api_client.find_mpxn(@meter.mpan_mprn)
    rescue StandardError => e
      Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
      {}
    end

    def available_data
      return [] unless @meter.dcc_meter?

      response = @api_client.consumption(@meter.mpan_mprn, @meter.fuel_type)
      return [] if response.dig('availableCacheRange', 'start').blank? &&
                   response.dig('availableCacheRange', 'end').blank?

      start_range = DateTime.parse(response['availableCacheRange']['start'])
      end_range = DateTime.parse(response['availableCacheRange']['end'])
      [start_range, end_range]
    rescue StandardError => e
      Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
      []
    end

    def inventory
      details = @api_client.read_inventory(device_type, mpxns: @meter.mpan_mprn)
      @api_client.fetch_with_retry(details['uri'], RETRY_INTERVAL, MAX_RETRIES)
    rescue StandardError
      nil
    end

    private

    def device_type
      @meter.gas? ? 'GSME' : 'ESME'
    end
  end
end

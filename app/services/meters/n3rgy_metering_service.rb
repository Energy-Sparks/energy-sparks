module Meters
  # Provides a set of useful methods for interacting with the n3rgy API to fetch
  # information about meters
  class N3rgyMeteringService
    RETRY_INTERVAL = 2
    MAX_RETRIES = 4

    def initialize(meter)
      @meter = meter
    end

    def self.consented_meters
      api_client = DataFeeds::N3rgy::DataApiClient.production_client
      response = api_client.list_consented_meters
      response['entries']
    rescue => e
      Rollbar.error(e)
      []
    end

    def status
      api_client.find_mpxn(@meter.mpan_mprn)
      :available
    rescue MeterReadingsFeeds::N3rgyDataApi::NotFound
      :unknown
    rescue MeterReadingsFeeds::N3rgyDataApi::NotAllowed
      :consent_required
    end

    def available?
      api_client.find_mpxn(@meter.mpan_mprn)
      true
    rescue
      false
    end

    def consented?
      return unless available?
      # need to be consented to call this successfully
      api_client.utilities(@meter.mpan_mprn)
      true
    rescue
      false
    end

    def find_mpxn
      api_client.find_mpxn(@meter.mpan_mprn)
    rescue => e
      Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
      {}
    end

    def available_data
      return [] unless @meter.dcc_meter?
      response = api_client.consumption(@meter.mpan_mprn, @meter.fuel_type)
      return [DateTime.parse(response['availableCacheRange']['start']), DateTime.parse(response['availableCacheRange']['end'])]
    rescue => e
      Rollbar.warning(e, meter: @meter.id, mpan: @meter.mpan_mprn)
      return [:api_error]
    end

    def inventory
      details = api_client.read_inventory(device_type, mpxns: @meter.mpan_mprn)
      api_client.fetch_with_retry(details['uri'], RETRY_INTERVAL, MAX_RETRIES)
    rescue
      nil
    end

    private

    def device_type
      @meter.gas? ? 'GSME' : 'ESME'
    end

    def api_client
      DataFeeds::N3rgy::DataApiClient.production_client
    end
  end
end

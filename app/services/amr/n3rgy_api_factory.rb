module Amr
  class N3rgyApiFactory
    def data_api(meter)
      meter.sandbox? ? sandbox_data_api : production_data_api
    end

    def consent_api(meter)
      meter.sandbox? ? sandbox_consent_api : production_consent_api
    end

    private

    def production_data_api
      @production_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_DATA_URL'])
    end

    def production_consent_api
      @production_consent_api ||= MeterReadingsFeeds::N3rgyConsent.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_CONSENT_URL'])
    end

    def sandbox_data_api
      @sandbox_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_SANDBOX_API_KEY'], base_url: ENV['N3RGY_SANDBOX_DATA_URL'], bad_electricity_standing_charge_units: true)
    end

    def sandbox_consent_api
      @sandbox_consent_api ||= MeterReadingsFeeds::N3rgyConsent.new(api_key: ENV['N3RGY_SANDBOX_API_KEY'], base_url: ENV['N3RGY_SANDBOX_CONSENT_URL'])
    end
  end
end

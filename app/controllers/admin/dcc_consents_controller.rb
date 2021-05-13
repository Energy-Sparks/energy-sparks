module Admin
  class DccConsentsController < AdminController
    def index
      if params[:sandbox]
        @dcc_consent_calcs = Meters::DccConsentCalcs.new(Meter.dcc, production_data_api.list + sandbox_data_api.list)
      else
        @dcc_consent_calcs = Meters::DccConsentCalcs.new(Meter.dcc.reject(&:sandbox), production_data_api.list)
      end
    end

    private

    def production_data_api
      @production_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_API_KEY'], base_url: ENV['N3RGY_DATA_URL'])
    end

    def sandbox_data_api
      @sandbox_data_api ||= MeterReadingsFeeds::N3rgyData.new(api_key: ENV['N3RGY_SANDBOX_API_KEY'], base_url: ENV['N3RGY_SANDBOX_DATA_URL'], bad_electricity_standing_charge_units: true)
    end
  end
end

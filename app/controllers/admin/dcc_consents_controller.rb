module Admin
  class DccConsentsController < AdminController
    def index
      if params[:sandbox]
        @dcc_consent_calcs = Meters::DccConsentCalcs.new(Meter.dcc, production_data_api.list + sandbox_data_api.list)
      else
        @dcc_consent_calcs = Meters::DccConsentCalcs.new(Meter.dcc.reject(&:sandbox), production_data_api.list)
      end
    end

    def grant
      meter = Meter.find_by_mpan_mprn(params[:mpxn])
      service = Meters::DccGrantTrustedConsents.new([meter])
      if service.perform
        redirect_back fallback_location: admin_dcc_consents_path, notice: "Consent granted for #{meter.mpan_mprn}"
      else
        redirect_back fallback_location: admin_dcc_consents_path, alert: service.errors.map(&:message).join('<br/>')
      end
    end

    def withdraw
      meter = Meter.find_by_mpan_mprn(params[:mpxn])
      service = Meters::DccWithdrawTrustedConsents.new([meter])
      if service.perform
        redirect_back fallback_location: admin_dcc_consents_path, notice: "Consent withdrawn for #{meter.mpan_mprn}"
      else
        redirect_back fallback_location: admin_dcc_consents_path, alert: service.errors.map(&:message).join('<br/>')
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

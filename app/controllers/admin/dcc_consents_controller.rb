module Admin
  class DccConsentsController < AdminController
    def index
      @dcc_consent_calcs = Meters::DccConsentCalcs.new(Meter.dcc, Meters::N3rgyMeteringService.consented_meters)
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
  end
end

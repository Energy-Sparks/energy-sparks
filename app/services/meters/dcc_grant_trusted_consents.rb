module Meters
  class DccGrantTrustedConsents
    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
    end

    def perform
      @meters.each do |meter|
        begin
          reference = meter.meter_review.consent_grant.guid
          @n3rgy_api_factory.consent_api(meter).grant_trusted_consent(meter.mpan_mprn, reference)
          meter.update(consent_granted: true)
        rescue => e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}")
          Rollbar.error(e, job: :dcc_grant_trusted_consents, mpxn: meter.mpan_mprn)
        end
      end
    end
  end
end

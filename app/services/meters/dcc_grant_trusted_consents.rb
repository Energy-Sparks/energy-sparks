module Meters
  class DccGrantTrustedConsents
    attr_reader :errors

    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
      @errors = []
    end

    def perform
      @meters.each do |meter|
        begin
          reference = meter.meter_review.consent_grant.guid
          @n3rgy_api_factory.consent_api(meter).grant_trusted_consent(meter.mpan_mprn, reference)
          meter.update(consent_granted: true)
        rescue => e
          @errors << e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
          Rollbar.error(e, job: :dcc_grant_trusted_consents, mpxn: meter.mpan_mprn, school_name: meter.school.name)
        end
      end
      return errors.empty?
    end
  end
end

module Meters
  class DccWithdrawTrustedConsents
    attr_reader :errors

    def initialize(meters, n3rgy_api_factory = Amr::N3rgyApiFactory.new)
      @meters = meters
      @n3rgy_api_factory = n3rgy_api_factory
      @errors = []
    end

    def perform
      @meters.each do |meter|
        meter.update(consent_granted: false)
        @n3rgy_api_factory.consent_api(meter).withdraw_trusted_consent(meter.mpan_mprn)
      rescue StandardError => e
        @errors << e
        Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
        Rollbar.error(e, job: :dcc_withdraw_trusted_consents, mpxn: meter.mpan_mprn, school_name: meter.school.name)
      end
      errors.empty?
    end
  end
end

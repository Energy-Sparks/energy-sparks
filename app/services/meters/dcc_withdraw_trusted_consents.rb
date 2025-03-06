module Meters
  class DccWithdrawTrustedConsents
    attr_reader :errors

    def initialize(meters)
      @meters = meters
      @errors = []
    end

    def perform
      @meters.each do |meter|
        begin
          meter.update(consent_granted: false)
          DataFeeds::N3rgy::ConsentApiClient.production_client.withdraw_consent(meter.mpan_mprn)
        rescue => e
          @errors << e
          Rails.logger.error("#{e.message} for mpxn #{meter.mpan_mprn}, school #{meter.school.name}")
          Rollbar.error(e, job: :dcc_withdraw_trusted_consents, mpxn: meter.mpan_mprn, school_name: meter.school.name)
        end
      end
      return errors.empty?
    end
  end
end
